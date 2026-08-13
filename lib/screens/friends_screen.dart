import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../data/game_content.dart';
import '../services/game_store.dart';
import 'duel_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final suggested = kBotNames.take(6).toList();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.magenta,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ArenaPalette.magenta)),
                  const Expanded(child: GlowText('RIVALS', size: 18, color: ArenaPalette.magenta)),
                ],
              ),
              HoloPanel(
                accent: ArenaPalette.cyan,
                child: Column(
                  children: [
                    const Text('YOUR ARENA CODE', style: TextStyle(letterSpacing: 2, fontSize: 11, color: ArenaPalette.mute, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    GlowText(store.arenaCode, size: 28),
                    const SizedBox(height: 10),
                    NeonButton(
                      label: 'COPY CODE',
                      icon: Icons.copy,
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: store.arenaCode));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arena code copied.')));
                      },
                    ),
                    const SizedBox(height: 8),
                    NeonButton(
                      label: 'SHARE CHALLENGE',
                      color: ArenaPalette.magenta,
                      icon: Icons.campaign,
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(
                          text: 'Challenge me on MindArena. Code ${store.arenaCode} — ${store.player.username}, PB ${store.player.bestScore}. Play for fun. Challenge your brain.',
                        ));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge invite copied.')));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Add by code or name (e.g. MA-004821)'),
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'ADD RIVAL',
                color: ArenaPalette.magenta,
                onTap: () async {
                  final err = await store.addFriend(_code.text);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Rival locked in.')));
                  if (err == null) _code.clear();
                },
              ),
              const SizedBox(height: 18),
              const Text('YOUR LIST', style: TextStyle(letterSpacing: 2, color: ArenaPalette.mute, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (store.player.friends.isEmpty)
                const Text('No rivals yet. Add a code or tap a suggested name.', style: TextStyle(color: ArenaPalette.mute))
              else
                for (final f in store.player.friends)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HoloPanel(
                      accent: ArenaPalette.magenta,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                                Text('${f.code}  •  ${f.country}', style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => store.removeFriend(f.code),
                            icon: const Icon(Icons.close, color: ArenaPalette.mute, size: 18),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DuelScreen(rival: f.name))),
                            child: const Text('DUEL', style: TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              const Text('SUGGESTED RIVALS', style: TextStyle(letterSpacing: 2, color: ArenaPalette.mute, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final n in suggested)
                ListTile(
                  tileColor: ArenaPalette.panel,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  title: Text(n, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(store.codeForName(n), style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
                  trailing: const Icon(Icons.person_add_alt, color: ArenaPalette.cyan),
                  onTap: () async {
                    final err = await store.addFriend(n);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Added $n')));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
