import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/question_bank.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'results_screen.dart';

class RushScreen extends StatefulWidget {
  const RushScreen({
    super.key,
    this.category,
    this.seconds = 60,
    this.mode = 'rush',
    this.title = '60 SECOND RUSH',
    this.difficulty = 'all',
    this.seed,
  });

  final GameCategory? category;
  final int seconds;
  final String mode;
  final String title;
  final String difficulty;
  final List<Question>? seed;

  @override
  State<RushScreen> createState() => _RushScreenState();
}

class _RushScreenState extends State<RushScreen> with TickerProviderStateMixin {
  final _rng = Random();
  late List<Question> _deck;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _remaining = 60;
  int? _selected;
  bool _locked = false;
  bool _counting = true;
  int _count = 3;
  String? _float;
  Color _floatColor = ArenaPalette.lime;
  bool _showWhy = false;
  late DateTime _shownAt;
  final List<int> _times = [];
  Timer? _timer;
  Timer? _cd;
  late AnimationController _shake;
  bool _done = false;
  late String _difficulty;
  bool _paused = false;
  final List<ReviewItem> _review = [];

  Question get _q => _deck[_index % _deck.length];

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _difficulty = widget.difficulty;
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _rebuildDeck();
    _shownAt = DateTime.now();
    _runCountdown();
  }

  void _rebuildDeck() {
    if (widget.seed != null && widget.seed!.isNotEmpty) {
      _deck = List<Question>.from(widget.seed!)..shuffle(_rng);
      return;
    }
    final source = widget.category == null ? mixedQuestions() : questionsFor(widget.category!);
    final filtered = filterByDifficulty(source, _difficulty);
    _deck = List<Question>.from(filtered)..shuffle(_rng);
    if (_deck.isEmpty) {
      _deck = List<Question>.from(kQuestionBank)..shuffle(_rng);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cd?.cancel();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _runCountdown() async {
    final store = context.read<GameStore>();
    if (store.player.skipCountdown) {
      await store.audio.playSfx('go');
      if (!mounted) return;
      setState(() {
        _counting = false;
        _rebuildDeck();
        _shownAt = DateTime.now();
      });
      _armClock();
      return;
    }
    final audio = store.audio;
    for (var i = 3; i >= 1; i--) {
      setState(() => _count = i);
      await audio.playSfx('countdown');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }
    setState(() => _count = 0);
    await audio.playSfx('go');
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    setState(() {
      _counting = false;
      _rebuildDeck();
      _shownAt = DateTime.now();
    });
    _armClock();
  }

  void _armClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _done || _paused) return;
      if (_locked && _showWhy) return;
      setState(() => _remaining--);
      if (_remaining == 10) {
        final s = context.read<GameStore>();
        if (s.player.haptics) HapticFeedback.heavyImpact();
        s.audio.playSfx('countdown');
      }
      if (_remaining <= 0) {
        _finish();
      }
    });
  }

  void _pick(int i) {
    if (_locked || _counting || _paused || _remaining <= 0) return;
    final audio = context.read<GameStore>().audio;
    final ms = DateTime.now().difference(_shownAt).inMilliseconds;
    _times.add(ms);
    final ok = i == _q.correctIndex;
    setState(() {
      _selected = i;
      _locked = true;
      _showWhy = !ok;
    });
    final store = context.read<GameStore>();
    if (store.player.haptics) HapticFeedback.lightImpact();
    _review.add(
      ReviewItem(
        prompt: _q.prompt,
        picked: _q.options[i],
        answer: _q.options[_q.correctIndex],
        why: _q.explanation,
        correct: ok,
      ),
    );
    if (ok) {
      audio.playSfx('correct');
      final speed = ms < 1600 ? 50 : (ms < 2800 ? 30 : (ms < 4000 ? 15 : 0));
      final gain = 100 + speed + (_streak >= 3 ? 15 : 0);
      setState(() {
        _score += gain;
        _correct++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        _float = (_streak == 5 || _streak == 8 || _streak == 12) ? 'COMBO x$_streak' : 'CORRECT  +$gain XP';
        _floatColor = ArenaPalette.lime;
      });
      if (_streak == 5 || _streak == 8 || _streak == 12) audio.playSfx('reward');
    } else {
      audio.playSfx('wrong');
      if (!store.player.reduceMotion) _shake.forward(from: 0);
      setState(() {
        _score = max(0, _score - 20);
        _wrong++;
        _streak = 0;
        _float = 'WRONG  -20';
        _floatColor = ArenaPalette.danger;
      });
    }
    Future<void>.delayed(Duration(milliseconds: ok ? 520 : 1600), _next);
  }

  void _next() {
    if (!mounted || _remaining <= 0) return;
    setState(() {
      _index++;
      _selected = null;
      _locked = false;
      _showWhy = false;
      _float = null;
      _shownAt = DateTime.now();
    });
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    if (!mounted) return;
    final store = context.read<GameStore>();
    final result = store.applyMatch(
      mode: widget.mode,
      category: widget.category,
      score: _score,
      correct: _correct,
      wrong: _wrong,
      answered: _correct + _wrong,
      bestStreak: _bestStreak,
      answerTimesMs: _times,
      won: _correct > _wrong,
      review: _review,
    );
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ResultsScreen(
          result: result,
          replay: () => RushScreen(
            category: widget.category,
            seconds: widget.seconds,
            mode: widget.mode,
            title: widget.title,
            difficulty: _difficulty,
            seed: widget.seed,
          ),
        ),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final ghost = store.lastScoreFor(widget.mode);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1): () => _pick(0),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _pick(1),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _pick(2),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _pick(3),
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (_counting || _done) return;
          setState(() => _paused = !_paused);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: widget.category?.accent ?? ArenaPalette.cyan,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_counting || _done) {
                              Navigator.pop(context);
                              return;
                            }
                            final leave = await confirmLeaveArena(context);
                            if (leave && context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: ArenaPalette.mute),
                        ),
                        Expanded(child: GlowText(widget.title, size: 14)),
                        IconButton(
                          onPressed: () {
                            if (_counting || _done) return;
                            setState(() => _paused = !_paused);
                          },
                          icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: ArenaPalette.cyan),
                        ),
                        Text('🏆 $_score', style: const TextStyle(fontWeight: FontWeight.w800, color: ArenaPalette.gold)),
                      ],
                    ),
                    Text('⏱️ $_remaining', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _remaining <= 10 ? ArenaPalette.danger : ArenaPalette.cyan)),
                    if (ghost > 0)
                      Text(
                        'GHOST $ghost${_score > ghost ? '  •  AHEAD' : _score == ghost ? '  •  TIED' : ''}',
                        style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                      ),
                    if (_streak >= 2) ...[
                      Text('🔥 STREAK $_streak', style: const TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: LinearProgressIndicator(
                          value: (_streak / 12).clamp(0, 1),
                          color: ArenaPalette.magenta,
                          backgroundColor: Colors.white10,
                          minHeight: 6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shake,
                      builder: (context, child) {
                        final dx = sin(_shake.value * pi * 8) * 10 * (1 - _shake.value);
                        return Transform.translate(offset: Offset(dx, 0), child: child);
                      },
                      child: HoloPanel(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text('QUESTION', style: TextStyle(color: ArenaPalette.cyan.withValues(alpha: 0.8), letterSpacing: 3, fontSize: 11)),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () async {
                                    await context.read<GameStore>().flagQuestion(_q.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Flagged for review. It will not auto-publish.')),
                                    );
                                  },
                                  icon: const Icon(Icons.flag_outlined, size: 18, color: ArenaPalette.mute),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(_q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
                          ],
                        ),
                      ),
                    ),
                    if (_float != null) ...[
                      const SizedBox(height: 10),
                      if (_floatColor == ArenaPalette.lime) const HitBurst(),
                      GlowText(_float!, size: 16, color: _floatColor).animate().scale(),
                    ],
                    const Spacer(),
                    for (var row = 0; row < 2; row++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            for (var col = 0; col < 2; col++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: col == 0 ? 0 : 6, right: col == 1 ? 0 : 6),
                                  child: _Option(
                                    label: _q.options[row * 2 + col],
                                    color: ArenaPalette.pads(store.player.colorblind)[row * 2 + col],
                                    selected: _selected == row * 2 + col,
                                    correct: _locked && (row * 2 + col) == _q.correctIndex,
                                    wrong: _locked && _selected == row * 2 + col && _selected != _q.correctIndex,
                                    onTap: () => _pick(row * 2 + col),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (_showWhy)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: HoloPanel(
                          accent: ArenaPalette.gold,
                          padding: const EdgeInsets.all(12),
                          child: Text('💡 DID YOU KNOW?\n${_q.explanation}', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.gold, height: 1.35, fontSize: 13)),
                        ),
                      ),
                  ],
                ),
              ),
              if (_paused && !_counting)
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: HoloPanel(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GlowText('PAUSED', size: 28, color: ArenaPalette.gold),
                          const SizedBox(height: 8),
                          const Text('Timer is frozen. Resume when you are ready.', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.mute)),
                          const SizedBox(height: 14),
                          NeonButton(label: 'RESUME', onTap: () => setState(() => _paused = false)),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              if (_counting)
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlowText(_count == 0 ? 'GO!' : '$_count', size: 88, color: _count == 0 ? ArenaPalette.lime : ArenaPalette.gold)
                            .animate(key: ValueKey(_count))
                            .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1))
                            .fadeIn(),
                        const SizedBox(height: 18),
                        const Text('DIFFICULTY', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2, fontSize: 11)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final d in const ['all', 'easy', 'medium', 'hard'])
                              ChoiceChip(
                                label: Text(d.toUpperCase()),
                                selected: _difficulty == d,
                                selectedColor: ArenaPalette.cyan.withValues(alpha: 0.35),
                                onSelected: (_) => setState(() => _difficulty = d),
                              ),
                          ],
                        ),
                        if (widget.mode == 'practice') ...[
                          const SizedBox(height: 10),
                          const Text('PRACTICE — half XP, no ranked best', style: TextStyle(color: ArenaPalette.gold, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.color,
    required this.onTap,
    required this.selected,
    required this.correct,
    required this.wrong,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final bool correct;
  final bool wrong;

  @override
  Widget build(BuildContext context) {
    final border = correct
        ? ArenaPalette.lime
        : wrong
            ? ArenaPalette.danger
            : color;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0014)
        ..rotateX(-0.16),
      child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 78,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.6),
          color: (correct ? ArenaPalette.lime : (wrong ? ArenaPalette.danger : color)).withValues(alpha: 0.16),
          boxShadow: [BoxShadow(color: border.withValues(alpha: 0.28), blurRadius: 12)],
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    ),
    );
  }
}
