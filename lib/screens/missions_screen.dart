import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../services/game_store.dart';
import 'accuracy_screen.dart';
import 'memory_screen.dart';
import 'rush_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GameStore>().ensureMissions();
    });
  }

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
                  const Expanded(child: GlowText('DAILY MISSIONS', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              Text(
                'Resets at midnight. ${store.seasonName} season — ${store.seasonDaysLeft} days left.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.mute),
              ),
              const SizedBox(height: 16),
              for (final m in store.todayMissions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HoloPanel(
                    accent: m.done ? ArenaPalette.lime : ArenaPalette.gold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text('${m.have.clamp(0, m.need)} / ${m.need}   •   +${m.xp} XP   +${m.coins} coins', style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (m.have / m.need).clamp(0, 1),
                          color: ArenaPalette.gold,
                          backgroundColor: Colors.white10,
                        ),
                        const SizedBox(height: 10),
                        NeonButton(
                          label: store.player.missionClaimed.contains(m.id)
                              ? 'CLAIMED'
                              : m.done
                                  ? 'CLAIM'
                                  : 'PLAY',
                          color: ArenaPalette.gold,
                          onTap: store.player.missionClaimed.contains(m.id)
                              ? null
                              : m.done
                                  ? () async {
                                      final err = await store.claimMission(m.id);
                                      if (!context.mounted) return;
                                      store.audio.playSfx('reward');
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Mission loot claimed.')));
                                    }
                                  : () {
                                      store.audio.playSfx('click');
                                      final page = switch (m.id) {
                                        'mini' => const MemoryScreen(),
                                        _ => const RushScreen(),
                                      };
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                                    },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              NeonButton(
                label: 'PLAY A RUSH',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RushScreen())),
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'PLAY A MINI-GAME',
                color: ArenaPalette.magenta,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccuracyScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
