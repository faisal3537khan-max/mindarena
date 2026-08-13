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

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key, this.rival});

  final String? rival;

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  late List<Question> _deck;
  int _i = 0;
  int _you = 0;
  int _cpu = 0;
  int _youHit = 0;
  int _youMiss = 0;
  int? _picked;
  bool _lock = false;
  late String _rival;
  String _phase = 'search';
  int _count = 3;
  DateTime _shownAt = DateTime.now();
  final List<int> _times = [];
  final List<ReviewItem> _review = [];
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _deck = List<Question>.from(kQuestionBank)..shuffle();
    _deck = _deck.take(8).toList();
    _rival = widget.rival ?? ['Ahmed', 'NovaBlade', 'ZaraVolt', 'Kairo'][Random().nextInt(4)];
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _phase = 'count');
    final audio = context.read<GameStore>().audio;
    for (var n = 3; n >= 1; n--) {
      setState(() => _count = n);
      await audio.playSfx('countdown');
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
    }
    await audio.playSfx('go');
    if (!mounted) return;
    setState(() {
      _phase = 'play';
      _shownAt = DateTime.now();
    });
  }

  Future<void> _pick(int idx) async {
    if (_lock || _phase != 'play' || _paused) return;
    final store = context.read<GameStore>();
    if (store.player.haptics) HapticFeedback.lightImpact();
    setState(() {
      _lock = true;
      _picked = idx;
    });
    _times.add(DateTime.now().difference(_shownAt).inMilliseconds);
    final q = _deck[_i];
    final youOk = idx == q.correctIndex;
    _review.add(
      ReviewItem(
        prompt: q.prompt,
        picked: q.options[idx],
        answer: q.options[q.correctIndex],
        why: q.explanation,
        correct: youOk,
      ),
    );
    final cpuOk = Random().nextDouble() < store.cpuHitChance;
    if (youOk) {
      _you += 140;
      _youHit++;
      store.audio.playSfx('correct');
    } else {
      _youMiss++;
      store.audio.playSfx('wrong');
    }
    if (cpuOk) _cpu += 110 + Random().nextInt(40);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (_i >= _deck.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _i++;
      _picked = null;
      _lock = false;
      _shownAt = DateTime.now();
    });
  }

  void _finish() {
    final store = context.read<GameStore>();
    final won = _you >= _cpu;
    final result = store.applyMatch(
      mode: 'duel',
      category: GameCategory.brain,
      score: _you,
      correct: _youHit,
      wrong: _youMiss,
      answered: _youHit + _youMiss,
      bestStreak: _youHit,
      answerTimesMs: _times.isEmpty ? const [900] : _times,
      won: won,
      review: _review,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(result: result, replay: () => DuelScreen(rival: _rival)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final q = _deck[_i];
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1): () => _pick(0),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _pick(1),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _pick(2),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _pick(3),
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (_phase != 'play') return;
          setState(() => _paused = !_paused);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.magenta,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (_phase != 'play') {
                              Navigator.pop(context);
                              return;
                            }
                            final leave = await confirmLeaveArena(context);
                            if (leave && context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: ArenaPalette.mute),
                        ),
                        const Expanded(child: GlowText('1v1 BATTLE', size: 16, color: ArenaPalette.magenta)),
                        if (_phase == 'play')
                          IconButton(
                            onPressed: () => setState(() => _paused = !_paused),
                            icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: ArenaPalette.cyan),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${store.player.username}\n$_you', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('Q ${_i + 1}/8', style: const TextStyle(color: ArenaPalette.mute)),
                        Text('$_rival\n$_cpu', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, color: ArenaPalette.magenta)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HoloPanel(child: Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                    const Spacer(),
                    ...List.generate(4, (i) {
                      final c = ArenaPalette.pads(store.player.colorblind)[i];
                      final mark = _picked == null
                          ? c
                          : (i == q.correctIndex ? ArenaPalette.lime : (_picked == i ? ArenaPalette.danger : c));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NeonButton(label: q.options[i], color: mark, onTap: () => _pick(i)),
                      );
                    }),
                  ],
                ),
              ),
              if (_phase != 'play')
                ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_phase == 'search') ...[
                          const GlowText('SEARCHING FOR RIVAL', size: 18, color: ArenaPalette.magenta),
                          const SizedBox(height: 10),
                          Text(_rival, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(height: 16),
                          const SizedBox(width: 140, child: LinearProgressIndicator(color: ArenaPalette.magenta, backgroundColor: Colors.white10)),
                        ] else
                          GlowText(_count == 0 ? 'GO!' : '$_count', size: 88, color: ArenaPalette.gold)
                              .animate(key: ValueKey(_count))
                              .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
              if (_paused && _phase == 'play')
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.62),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GlowText('PAUSED', size: 28, color: ArenaPalette.cyan),
                          const SizedBox(height: 16),
                          NeonButton(label: 'RESUME', onTap: () => setState(() => _paused = false)),
                        ],
                      ),
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
