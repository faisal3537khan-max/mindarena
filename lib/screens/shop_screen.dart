import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/game_content.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'home_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

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
                  const Expanded(child: GlowText('COSMETICS', size: 18, color: ArenaPalette.gold)),
                ],
              ),
              Text(
                '${p.coins} COINS${p.isPremium ? '  •  PLUS' : ''}${p.doubleXpLive ? '  •  2× XP LIVE' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              const Text(
                'Looks only. Nothing here changes questions, timers, or ranks.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ArenaPalette.mute, fontSize: 12),
              ),
              const SizedBox(height: 14),
              for (final item in kShop)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HoloPanel(
                    accent: p.unlocked.contains(item.id) ? ArenaPalette.lime : ArenaPalette.gold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(item.blurb, style: const TextStyle(color: ArenaPalette.mute, fontSize: 12, height: 1.35)),
                        const SizedBox(height: 10),
                        NeonButton(
                          label: p.unlocked.contains(item.id)
                              ? 'EQUIP'
                              : item.plusOnly
                                  ? 'PLUS EXCLUSIVE'
                                  : item.cost == 0
                                      ? 'EQUIP'
                                      : 'BUY  ${item.cost}',
                          color: p.unlocked.contains(item.id) ? ArenaPalette.lime : ArenaPalette.gold,
                          onTap: () async {
                            if (p.unlocked.contains(item.id) || item.cost == 0) {
                              await store.equipItem(item);
                              if (!context.mounted) return;
                              store.audio.playSfx('click');
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Equipped ${item.name}')));
                              return;
                            }
                            final err = await store.buyItem(item);
                            if (!context.mounted) return;
                            if (err == null) await store.equipItem(item);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err ?? 'Unlocked ${item.name}')),
                            );
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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final rows = store.player.history.where((m) => _filter == 'all' || m.mode == _filter).toList();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('MATCH HISTORY', size: 16)),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final f in const ['all', 'rush', 'practice', 'daily', 'duel', 'weekly', 'tournament', 'reaction', 'memory', 'accuracy'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(f.toUpperCase()),
                          selected: _filter == f,
                          selectedColor: ArenaPalette.cyan.withValues(alpha: 0.3),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('No runs in this filter.', style: TextStyle(color: ArenaPalette.mute)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rows.length,
                        itemBuilder: (_, i) {
                          final m = rows[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: HoloPanel(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${m.mode.toUpperCase()}  •  ${m.at}${m.signature.isNotEmpty ? '  •  signed' : ''}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    '${m.won ? 'W' : 'L'}  ${m.score}',
                                    style: TextStyle(
                                      color: m.won ? ArenaPalette.lime : ArenaPalette.danger,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => continuePlay(store.player, m.mode)),
                                      );
                                    },
                                    icon: const Icon(Icons.replay, color: ArenaPalette.cyan, size: 20),
                                  ),
                                ],
                              ),
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

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArenaBackground(
        quality: GraphicsQuality.medium,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.cyan)),
                  const Expanded(child: GlowText('PRIVACY & TERMS', size: 14)),
                ],
              ),
              const HoloPanel(
                child: Text(
                  'MindArena stores your profile, scores, cosmetics, and match history on this device. Guest play does not require an email.\n\n'
                  'This build mixes your real best score with a seeded rival field so competition works offline. A live season must validate scores on a server — never trust the phone alone.\n\n'
                  'MindArena Plus and the shop sell cosmetics only. They never change difficulty, timers, or ranking math.\n\n'
                  'You can log out or delete the local account from Settings. Connecting Firebase Auth, Firestore, Crashlytics, and Cloud Messaging is the production next step.\n\n'
                  'Play fair. No harassment. Report abuse when online services are enabled.',
                  style: TextStyle(height: 1.45, color: ArenaPalette.mute),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showRewardedPreview(BuildContext context) async {
  final store = context.read<GameStore>();
  if (store.player.isPremium) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plus already removes ads.')));
    return;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ArenaPalette.deepNavy,
      title: const Text('Rewarded boost'),
      content: const Text('A short placeholder stands in for a real ad network. Collect 2× XP for 20 minutes plus bonus coins.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('SKIP')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('COLLECT')),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await store.grantRewardedBoost();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2× XP is live. Go play.')));
    }
  }
}
