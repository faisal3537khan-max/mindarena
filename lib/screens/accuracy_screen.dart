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

class AccuracyScreen extends StatefulWidget {
  const AccuracyScreen({super.key});

  @override
  State<AccuracyScreen> createState() => _AccuracyScreenState();
}

class _AccuracyScreenState extends State<AccuracyScreen> {
  final _rng = Random();
  Offset _pos = const Offset(0.5, 0.5);
  int _left = 30;
  int _hits = 0;
  int _miss = 0;
  int _score = 0;
  Timer? _t;
  Timer? _move;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      setState(() => _left--);
      if (_left <= 0) _finish();
    });
    _move = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (_paused) return;
      setState(() => _pos = Offset(0.18 + _rng.nextDouble() * 0.64, 0.18 + _rng.nextDouble() * 0.64));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _move?.cancel();
    super.dispose();
  }

  void _hit() {
    if (_paused) return;
    if (context.read<GameStore>().player.haptics) HapticFeedback.selectionClick();
    context.read<GameStore>().audio.playSfx('correct');
    setState(() {
      _hits++;
      _score += 120;
      _pos = Offset(0.18 + _rng.nextDouble() * 0.64, 0.18 + _rng.nextDouble() * 0.64);
    });
  }

  void _finish() {
    _t?.cancel();
    _move?.cancel();
    final store = context.read<GameStore>();
    final result = store.applyMatch(
      mode: 'accuracy',
      category: GameCategory.accuracy,
      score: _score,
      correct: _hits,
      wrong: _miss,
      answered: _hits + _miss,
      bestStreak: _hits,
      answerTimesMs: List.filled(max(1, _hits), 700),
      won: _hits >= 8,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result, replay: () => const AccuracyScreen())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.danger,
        child: SafeArea(
          child: Column(
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
                    const Expanded(child: GlowText('ACCURACY ARENA', size: 16)),
                    IconButton(
                      onPressed: () => setState(() => _paused = !_paused),
                      icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: ArenaPalette.cyan),
                    ),
                  ],
                ),
              ),
              Text('⏱️ $_left   •   HITS $_hits   •   $_score', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = 64.0;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_paused) return;
                        setState(() {
                          _miss++;
                          _score = max(0, _score - 15);
                        });
                        context.read<GameStore>().audio.playSfx('wrong');
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            left: _pos.dx * box.maxWidth - size / 2,
                            top: _pos.dy * box.maxHeight - size / 2,
                            child: GestureDetector(
                              onTap: _hit,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(colors: [ArenaPalette.gold, ArenaPalette.danger]),
                                  boxShadow: [BoxShadow(color: ArenaPalette.danger.withValues(alpha: 0.5), blurRadius: 16)],
                                ),
                                child: const Center(child: Text('◎', style: TextStyle(fontSize: 26))),
                              ),
                            ),
                          ),
                          if (_paused)
                            Positioned.fill(
                              child: ColoredBox(
                                color: Colors.black.withValues(alpha: 0.55),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
