import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/game_content.dart';
import '../services/game_store.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.gold,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.gold)),
                  const Expanded(child: GlowText('ACHIEVEMENTS', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              ...kAchievements.map((a) {
                final got = store.player.achievements.contains(a.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ArenaPalette.panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: got ? ArenaPalette.gold : Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Icon(a.icon, color: got ? ArenaPalette.gold : ArenaPalette.mute, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: TextStyle(fontWeight: FontWeight.w800, color: got ? ArenaPalette.gold : ArenaPalette.text)),
                            Text(a.description, style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('+${a.xp}', style: const TextStyle(color: ArenaPalette.cyan, fontWeight: FontWeight.w800)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
