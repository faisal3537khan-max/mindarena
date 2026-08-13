import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../services/game_store.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  static const _steps = [
    ('⚡', 'PLAY NOW', 'A 60-second rush. 3-2-1-GO, then fire as fast as you can. Faster answers pay a speed bonus.'),
    ('💡', 'MISSES PAUSE THE CLOCK', 'Wrong answers show Did you know? The timer holds so you can actually learn, then you keep going.'),
    ('🎯', 'PRACTICE VS RANKED', 'Practice is half XP and never touches personal best, season, or weekly boards. Ranked runs do.'),
    ('🏆', 'BOARDS & SEASONS', 'Global, country, campus, season, and weekly. Cosmetics never change questions, timers, or ranks.'),
    ('🤝', 'RIVALS', 'Share your arena code. Challenge a saved rival to the same 8-question 1v1 gauntlet.'),
    ('📅', 'DAILY LOOP', 'Claim streak loot, finish the rotating daily category, and clear three missions for extra coins.'),
    ('📓', 'MISS NOTEBOOK', 'Wrong answers land in your notebook. Drill them as a practice rush so the same trap does not land twice.'),
    ('📈', 'DAILY XP', 'Hit 400 XP in a day for Daily Grind. Cosmetics never change questions, timers, or ranks.'),
  ];

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
                  const Expanded(child: GlowText('HOW TO PLAY', size: 18)),
                ],
              ),
              const Text(
                'Play for fun. Challenge your brain. Compete with everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ArenaPalette.mute, height: 1.4),
              ),
              const SizedBox(height: 16),
              for (final s in _steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HoloPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.$1}  ${s.$2}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        const SizedBox(height: 6),
                        Text(s.$3, style: const TextStyle(color: ArenaPalette.mute, height: 1.4)),
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
