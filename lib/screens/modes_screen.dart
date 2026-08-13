import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'accuracy_screen.dart';
import 'duel_screen.dart';
import 'memory_screen.dart';
import 'reaction_screen.dart';
import 'rush_screen.dart';
import 'tournament_screen.dart';

class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('GAME MODES', size: 18)),
                ],
              ),
              const SizedBox(height: 8),
              NeonButton(
                label: '1v1 BATTLE  vs CPU',
                color: ArenaPalette.magenta,
                icon: Icons.people_alt,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuelScreen())),
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'TOURNAMENTS',
                color: ArenaPalette.gold,
                icon: Icons.emoji_events,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentScreen())),
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'PRACTICE RUSH',
                color: ArenaPalette.electric,
                icon: Icons.fitness_center,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RushScreen(mode: 'practice', title: 'PRACTICE RUSH')),
                ),
              ),
              const SizedBox(height: 16),
              ...GameCategory.values.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () {
                      store.audio.playSfx('click');
                      Widget page;
                      if (c == GameCategory.reaction) {
                        page = const ReactionScreen();
                      } else if (c == GameCategory.memory) {
                        page = const MemoryScreen();
                      } else if (c == GameCategory.accuracy) {
                        page = const AccuracyScreen();
                      } else {
                        page = RushScreen(category: c, title: c.title.toUpperCase());
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    tileColor: ArenaPalette.panel,
                    leading: CircleAvatar(
                      backgroundColor: c.accent.withValues(alpha: 0.2),
                      child: Icon(c.icon, color: c.accent),
                    ),
                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(c.tagline, style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                    trailing: Icon(Icons.play_arrow, color: c.accent),
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
