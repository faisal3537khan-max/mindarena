import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../services/game_store.dart';
import 'rush_screen.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final campuses = store.universityTotals().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
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
                  const Expanded(child: GlowText('TOURNAMENTS', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              const SizedBox(height: 8),
              _card(
                title: 'DAILY TOURNAMENT',
                body: '100 challengers. Top 10 take the spoils. One run per day.',
                locked: !store.canTournament,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RushScreen(mode: 'tournament', title: 'DAILY TOURNAMENT', seconds: 75),
                  ),
                ),
              ),
              _card(
                title: 'WEEKLY CHAMPIONSHIP',
                body: 'Best this week: ${store.weeklyBestLive}. Resets Monday. A 90-second gauntlet on a 1,000-player field.',
                locked: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RushScreen(mode: 'weekly', title: 'WEEKLY CHAMPIONSHIP', seconds: 90),
                  ),
                ),
              ),
              _card(
                title: 'UNIVERSITY CHAMPIONSHIP',
                body: 'Points you earn feed ${store.player.university}. Set your campus in Profile.',
                locked: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RushScreen(mode: 'rush', title: 'UNIVERSITY CUP', seconds: 60),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              HoloPanel(
                accent: ArenaPalette.cyan,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CAMPUS STANDINGS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    for (var i = 0; i < campuses.length && i < 8; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 32, child: Text('#${i + 1}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w900))),
                            Expanded(child: Text(campuses[i].key, style: const TextStyle(fontWeight: FontWeight.w700))),
                            Text('${campuses[i].value}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required String body, required bool locked, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoloPanel(
        accent: ArenaPalette.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: ArenaPalette.gold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(color: ArenaPalette.mute, height: 1.4)),
            const SizedBox(height: 12),
            NeonButton(label: locked ? 'COME BACK TOMORROW' : 'ENTER', color: ArenaPalette.gold, onTap: locked ? null : onTap),
          ],
        ),
      ),
    );
  }
}
