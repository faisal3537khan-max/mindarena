import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../core/widgets/avatar_view.dart';
import '../data/game_content.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'achievements_screen.dart';
import 'auth_screen.dart';
import 'avatar_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'review_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  const Expanded(child: GlowText('PROFILE', size: 18)),
                ],
              ),
              AvatarView(config: p.avatar, size: 150),
              GlowText(p.username, size: 22),
              TextButton(
                onPressed: () => _editName(context, store),
                child: const Text('EDIT ARENA NAME', style: TextStyle(color: ArenaPalette.cyan, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
              ),
              Text(
                store.arenaCode,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.gold, letterSpacing: 2, fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: '${p.username} ${store.arenaCode} — MindArena rival code'));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arena card copied.')));
                },
                child: const Text('COPY ARENA CARD', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 1, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              Text('${p.provider.name.toUpperCase()}  •  ${p.rankTitle}', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.mute)),
              const SizedBox(height: 10),
              XpBar(progress: p.levelProgress),
              const SizedBox(height: 6),
              Text('LV ${p.level}   ${p.xp} XP   ${p.coins} coins', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.gold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _chip('Games ${p.totalGames}'),
                  _chip('Wins ${p.wins}'),
                  _chip('Best ${p.bestScore}'),
                  _chip('Streak ${p.streak}'),
                  if (p.bestMemoryMs > 0) _chip('Memory ${(p.bestMemoryMs / 1000).toStringAsFixed(1)}s'),
                  _chip('Win streak ${p.matchWinStreak}'),
                  _chip('Best win streak ${p.bestWinStreak}'),
                ],
              ),
              const SizedBox(height: 16),
              HoloPanel(
                child: Column(
                  children: [
                    _picker(context, 'Country', p.country, kCountries, (v) => store.updateIdentity(country: v)),
                    const Divider(color: Colors.white12),
                    _picker(context, 'University', p.university, kUniversities, (v) => store.updateIdentity(university: v)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              NeonButton(label: 'CUSTOMIZE AVATAR', icon: Icons.checkroom, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'COSMETIC SHOP', color: ArenaPalette.gold, icon: Icons.storefront, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'MATCH HISTORY', color: ArenaPalette.cyan, icon: Icons.history, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'MISS NOTEBOOK', color: ArenaPalette.electric, icon: Icons.menu_book, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotebookScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'ARENA STATS', color: ArenaPalette.electric, icon: Icons.insights, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'ACHIEVEMENTS', color: ArenaPalette.gold, icon: Icons.military_tech, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()))),
              const SizedBox(height: 10),
              NeonButton(label: 'SETTINGS', color: ArenaPalette.electric, icon: Icons.tune, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
              const SizedBox(height: 10),
              if (p.provider == AuthProviderType.guest)
                NeonButton(
                  label: 'SAVE YOUR SCORE',
                  color: ArenaPalette.magenta,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, GameStore store) async {
    final c = TextEditingController(text: store.player.username);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArenaPalette.deepNavy,
        title: const Text('ARENA NAME'),
        content: TextField(
          controller: c,
          maxLength: 18,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'At least 3 characters'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SAVE')),
        ],
      ),
    );
    if (ok == true && c.text.trim().length >= 3) {
      await store.updateIdentity(username: c.text);
    }
    c.dispose();
  }

  Widget _chip(String t) => Chip(
        label: Text(t),
        backgroundColor: ArenaPalette.panel,
        side: BorderSide(color: ArenaPalette.cyan.withValues(alpha: 0.3)),
      );

  Widget _picker(BuildContext context, String label, String value, List<String> items, ValueChanged<String> onPick) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      trailing: const Icon(Icons.edit, color: ArenaPalette.cyan, size: 18),
      onTap: () async {
        final v = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: ArenaPalette.deepNavy,
          builder: (ctx) => ListView(
            children: items
                .map((e) => ListTile(
                      title: Text(e),
                      onTap: () => Navigator.pop(ctx, e),
                    ))
                .toList(),
          ),
        );
        if (v != null) onPick(v);
      },
    );
  }
}
