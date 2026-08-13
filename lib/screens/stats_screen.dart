import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final p = store.player;
    return Scaffold(
      body: ArenaBackground(
        quality: p.quality,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('ARENA STATS', size: 18)),
                ],
              ),
              HoloPanel(
                child: Column(
                  children: [
                    _row('Lifetime accuracy', '${store.lifetimeAccuracy}%'),
                    _row('Games', '${p.totalGames}'),
                    _row('Wins', '${p.wins}'),
                    _row('Win streak', '${p.matchWinStreak} (best ${p.bestWinStreak})'),
                    _row('Best rush', '${p.bestScore}'),
                    _row('Weekly best', '${store.weeklyBestLive}'),
                    _row('Season', store.seasonName),
                    _row('Season points', '${p.seasonPoints}'),
                    _row('Favorite arena', store.favoriteArena),
                    _row('Fast answers', '${p.fastAnswers}'),
                    _row('Best accuracy', '${p.bestAccuracy}%'),
                    _row('Best reaction', p.bestReactionMs == 0 ? '—' : '${p.bestReactionMs} ms'),
                    _row('Best memory', p.bestMemoryMs == 0 ? '—' : '${(p.bestMemoryMs / 1000).toStringAsFixed(1)}s'),
                    _row('Streak savers', '${p.streakSavers}'),
                    _row('Campus points', '${p.universityPoints}'),
                    _row('Playtime today', '${p.playSecondsToday ~/ 60}m ${p.playSecondsToday % 60}s'),
                    _row('XP today', '${store.xpTodayLive} / 400'),
                  ],
                ),
              ),
              if (p.history.length >= 2) ...[
                const SizedBox(height: 12),
                HoloPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LAST 10 SCORES', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w900, fontSize: 12, color: ArenaPalette.mute)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _SparkPainter(
                            scores: p.history.take(10).map((e) => e.score).toList().reversed.toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (p.categoryBest.isNotEmpty)
                HoloPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CATEGORY BESTS', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w900, fontSize: 12, color: ArenaPalette.mute)),
                      const SizedBox(height: 8),
                      for (final e in p.categoryBest.entries)
                        _row(
                          GameCategory.values
                              .firstWhere((c) => c.name == e.key, orElse: () => GameCategory.brain)
                              .title,
                          '${e.value}',
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'These numbers stay on-device until a Firebase project is connected. They already answer DAU-style questions for a single player: what they play, how long they last, and whether they come back.',
                style: TextStyle(color: ArenaPalette.mute, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: ArenaPalette.mute))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.scores});
  final List<int> scores;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    final hi = scores.reduce(max).clamp(1, 999999);
    final lo = scores.reduce(min);
    final span = max(1, hi - lo);
    final paint = Paint()
      ..color = ArenaPalette.cyan
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < scores.length; i++) {
      final x = scores.length == 1 ? size.width / 2 : i * size.width / (scores.length - 1);
      final y = size.height - ((scores[i] - lo) / span) * (size.height - 8) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.scores != scores;
}
