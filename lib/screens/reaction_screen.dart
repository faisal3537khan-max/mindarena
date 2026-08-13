import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'results_screen.dart';

class ReactionScreen extends StatefulWidget {
  const ReactionScreen({super.key});

  @override
  State<ReactionScreen> createState() => _ReactionScreenState();
}

class _ReactionScreenState extends State<ReactionScreen> {
  final _rng = Random();
  String _phase = 'wait';
  int _round = 0;
  int _score = 0;
  int _hits = 0;
  int _miss = 0;
  final List<int> _times = [];
  int? _lastMs;
  bool _paused = false;
  Timer? _arm;
  DateTime? _goAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _armRound());
  }

  @override
  void dispose() {
    _arm?.cancel();
    super.dispose();
  }

  void _scheduleGo() {
    _arm?.cancel();
    _arm = Timer(Duration(milliseconds: 700 + _rng.nextInt(1600)), () {
      if (!mounted) return;
      if (_paused) return;
      setState(() {
        _phase = 'go';
        _goAt = DateTime.now();
      });
      context.read<GameStore>().audio.playSfx('go');
    });
  }

  void _armRound() {
    if (_round >= 8) {
      _finish();
      return;
    }
    setState(() => _phase = 'wait');
    _scheduleGo();
  }

  void _togglePause() {
    if (_phase == 'go') return;
    setState(() => _paused = !_paused);
    if (_paused) {
      _arm?.cancel();
    } else if (_phase == 'wait') {
      _scheduleGo();
    }
  }

  void _tap() {
    if (_paused) return;
    if (context.read<GameStore>().player.haptics) HapticFeedback.mediumImpact();
    if (_phase == 'wait') {
      _arm?.cancel();
      setState(() {
        _miss++;
        _phase = 'fail';
        _score = max(0, _score - 30);
      });
      context.read<GameStore>().audio.playSfx('wrong');
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _round++);
        _armRound();
      });
      return;
    }
    if (_phase != 'go') return;
    final ms = DateTime.now().difference(_goAt!).inMilliseconds;
    _times.add(ms);
    _lastMs = ms;
    final gain = (420 - ms).clamp(40, 380);
    setState(() {
      _hits++;
      _score += gain;
      _phase = 'hit';
      _round++;
    });
    context.read<GameStore>().audio.playSfx('correct');
    Future<void>.delayed(const Duration(milliseconds: 500), _armRound);
  }

  void _finish() {
    final store = context.read<GameStore>();
    final result = store.applyMatch(
      mode: 'reaction',
      category: GameCategory.reaction,
      score: _score,
      correct: _hits,
      wrong: _miss,
      answered: _hits + _miss,
      bestStreak: _hits,
      answerTimesMs: _times,
      won: _hits > _miss,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(result: result, replay: () => const ReactionScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final color = switch (_phase) {
      'go' => ArenaPalette.lime,
      'fail' => ArenaPalette.danger,
      'hit' => ArenaPalette.cyan,
      _ => ArenaPalette.magenta,
    };
    final label = switch (_phase) {
      'go' => 'TAP!',
      'fail' => 'TOO EARLY',
      'hit' => 'CLEAN',
      _ => 'WAIT...',
    };
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.magenta,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final leave = await confirmLeaveArena(context);
                        if (leave && context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: ArenaPalette.mute),
                    ),
                    const Expanded(child: GlowText('REACTION ARENA', size: 16)),
                    IconButton(
                      onPressed: _togglePause,
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: ArenaPalette.cyan),
                    ),
                  ],
                ),
              ),
              Text('Round ${_round.clamp(0, 8)} / 8   •   $_score', style: const TextStyle(color: ArenaPalette.mute)),
              const SizedBox(height: 6),
              Text(
                'BEST ${store.player.bestReactionMs == 0 ? '—' : '${store.player.bestReactionMs} ms'}   •   LAST ${_lastMs == null ? '—' : '$_lastMs ms'}',
                style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.6),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _tap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 240,
                  height: 240,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                    border: Border.all(color: color, width: 4),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 28)],
                  ),
                  child: GlowText(label, size: 28, color: color),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Wait for green. Tap the instant it hits.', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.mute)),
              ),
            ],
              ),
              if (_paused)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.62),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GlowText('PAUSED', size: 28, color: ArenaPalette.cyan),
                          const SizedBox(height: 16),
                          NeonButton(label: 'RESUME', onTap: _togglePause),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
