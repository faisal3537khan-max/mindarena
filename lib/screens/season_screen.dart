import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/game_content.dart';
import '../services/game_store.dart';

class SeasonScreen extends StatelessWidget {
  const SeasonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final p = store.player;
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
                  const Expanded(child: GlowText('SEASON TRACK', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              GlowText(store.seasonName, size: 22, color: ArenaPalette.gold),
              Text(
                '${p.seasonPoints} season points  •  ${store.seasonDaysLeft} days left',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.mute),
              ),
              const SizedBox(height: 8),
              const Text(
                'Looks and coins only. Nothing on this track changes questions or ranks.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ArenaPalette.mute, fontSize: 12),
              ),
              const SizedBox(height: 16),
              for (final t in kSeasonTrack)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HoloPanel(
                    accent: p.seasonPoints >= t.points ? ArenaPalette.lime : ArenaPalette.gold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t.points} PTS  •  ${t.label.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (t.coins > 0) '+${t.coins} coins',
                            if (t.item != null) t.item!.replaceAll('_', ' '),
                          ].join('  •  '),
                          style: const TextStyle(color: ArenaPalette.mute, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        NeonButton(
                          label: p.seasonClaimed.contains('${t.points}')
                              ? 'CLAIMED'
                              : p.seasonPoints >= t.points
                                  ? 'CLAIM'
                                  : 'LOCKED',
                          color: ArenaPalette.gold,
                          onTap: p.seasonClaimed.contains('${t.points}') || p.seasonPoints < t.points
                              ? null
                              : () async {
                                  final err = await store.claimSeason(t.points);
                                  if (!context.mounted) return;
                                  store.audio.playSfx('reward');
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Season loot unlocked.')));
                                },
                        ),
                      ],
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
