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

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late List<int> _values;
  late List<bool> _open;
  late List<bool> _done;
  int? _first;
  int _moves = 0;
  int _matches = 0;
  bool _lock = false;
  bool _paused = false;
  final _clock = Stopwatch()..start();
  Timer? _tick;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    final pairs = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]..shuffle();
    _values = pairs;
    _open = List.filled(16, false);
    _done = List.filled(16, false);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      setState(() => _elapsed = _clock.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _clock.stop();
      } else {
        _clock.start();
      }
    });
  }

  Future<void> _tap(int i) async {
    if (_paused || _lock || _done[i] || _open[i]) return;
    final store = context.read<GameStore>();
    if (store.player.haptics) HapticFeedback.selectionClick();
    setState(() => _open[i] = true);
    store.audio.playSfx('click');
    if (_first == null) {
      _first = i;
      return;
    }
    _moves++;
    if (_values[_first!] == _values[i]) {
      setState(() {
        _done[_first!] = true;
        _done[i] = true;
        _matches++;
        _first = null;
      });
      store.audio.playSfx('correct');
      if (_matches == 8) _finish();
    } else {
      _lock = true;
      store.audio.playSfx('wrong');
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() {
        _open[_first!] = false;
        _open[i] = false;
        _first = null;
        _lock = false;
      });
    }
  }

  void _finish() {
    _clock.stop();
    _tick?.cancel();
    final ms = _clock.elapsedMilliseconds;
    final score = max(200, 2400 - _moves * 80 - ms ~/ 40);
    final store = context.read<GameStore>();
    final result = store.applyMatch(
      mode: 'memory',
      category: GameCategory.memory,
      score: score,
      correct: 8,
      wrong: max(0, _moves - 8),
      answered: _moves,
      bestStreak: 8,
      answerTimesMs: [ms],
      won: true,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result, replay: () => const MemoryScreen())),
    );
  }

  static const icons = [
    Icons.bolt,
    Icons.star,
    Icons.favorite,
    Icons.public,
    Icons.science,
    Icons.terminal,
    Icons.psychology,
    Icons.music_note,
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final best = store.player.bestMemoryMs;
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
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
                        const Expanded(child: GlowText('MEMORY ARENA', size: 16)),
                        IconButton(
                          onPressed: _togglePause,
                          icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: ArenaPalette.cyan),
                        ),
                      ],
                    ),
                  ),
                  Text('Matches $_matches / 8   •   Moves $_moves   •   ${_elapsed}s', style: const TextStyle(color: ArenaPalette.mute)),
                  const SizedBox(height: 4),
                  Text(
                    'BEST ${best == 0 ? '—' : '${(best / 1000).toStringAsFixed(1)}s'}',
                    style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemCount: 16,
                      itemBuilder: (_, i) {
                        final show = _open[i] || _done[i];
                        return GestureDetector(
                          onTap: () => _tap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: show ? ArenaPalette.cyan.withValues(alpha: 0.18) : ArenaPalette.panel,
                              border: Border.all(color: show ? ArenaPalette.cyan : ArenaPalette.magenta.withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: show ? Icon(icons[_values[i]], color: ArenaPalette.cyan, size: 28) : const Text('?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        );
                      },
                    ),
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
