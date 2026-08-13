import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/game_content.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'rush_screen.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final p = store.player;
    final idx = ((p.streak == 0 ? 0 : p.streak - 1) % 7);
    return Scaffold(
      body: ArenaBackground(
        quality: p.quality,
        accent: ArenaPalette.gold,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.gold)),
                  const Expanded(child: GlowText('DAILY STREAK', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              GlowText('🔥 ${p.streak} DAY STREAK', size: 24, color: ArenaPalette.gold),
              const SizedBox(height: 16),
              ...kDailyRewards.map((r) {
                final active = r.day == idx + 1;
                final done = r.day <= idx && p.lastDailyClaim == store.todayStamp || r.day < idx + 1 && p.streak > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: ArenaPalette.panel,
                    border: Border.all(color: active ? ArenaPalette.gold : Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Text('DAY ${r.day}', style: const TextStyle(fontWeight: FontWeight.w800, color: ArenaPalette.gold)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(r.label)),
                      if (done) const Icon(Icons.check_circle, color: ArenaPalette.lime),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              NeonButton(
                label: store.canClaimDaily ? 'CLAIM TODAY' : 'ALREADY CLAIMED',
                color: ArenaPalette.gold,
                onTap: store.canClaimDaily
                    ? () async {
                        final r = await store.claimDaily();
                        if (!context.mounted || r == null) return;
                        store.audio.playSfx('reward');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claimed ${r.label}')));
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: store.canDailyChallenge ? 'START ${store.dailyCategory.title.toUpperCase()}' : 'GAUNTLET DONE TODAY',
                color: ArenaPalette.cyan,
                onTap: store.canDailyChallenge
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RushScreen(
                              mode: 'daily',
                              title: 'DAILY • ${store.dailyCategory.title.toUpperCase()}',
                              seconds: 60,
                              category: store.dailyCategory,
                            ),
                          ),
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
