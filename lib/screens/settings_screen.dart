import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'shop_screen.dart';
import 'splash_screen.dart';
import 'pipeline_screen.dart';
import 'how_to_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  const Expanded(child: GlowText('SETTINGS', size: 18)),
                ],
              ),
              SwitchListTile(
                value: p.music,
                activeThumbColor: ArenaPalette.cyan,
                title: const Text('Music'),
                subtitle: const Text('Arena ambience', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setAudio(music: v),
              ),
              SwitchListTile(
                value: p.sfx,
                activeThumbColor: ArenaPalette.magenta,
                title: const Text('Sound effects'),
                subtitle: const Text('Clicks, hits, victories', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setAudio(sfx: v),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MUSIC  ${p.musicVol}', style: const TextStyle(color: ArenaPalette.mute, letterSpacing: 1.4, fontWeight: FontWeight.w800, fontSize: 11)),
                    Slider(
                      value: p.musicVol.toDouble(),
                      min: 0,
                      max: 100,
                      activeColor: ArenaPalette.cyan,
                      onChanged: p.music ? (v) => store.setVolumes(musicVol: v.round(), persist: false) : null,
                      onChangeEnd: p.music ? (v) => store.setVolumes(musicVol: v.round()) : null,
                    ),
                    Text('SFX  ${p.sfxVol}', style: const TextStyle(color: ArenaPalette.mute, letterSpacing: 1.4, fontWeight: FontWeight.w800, fontSize: 11)),
                    Slider(
                      value: p.sfxVol.toDouble(),
                      min: 0,
                      max: 100,
                      activeColor: ArenaPalette.magenta,
                      onChanged: p.sfx ? (v) => store.setVolumes(sfxVol: v.round(), persist: false) : null,
                      onChangeEnd: p.sfx ? (v) => store.setVolumes(sfxVol: v.round()) : null,
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                value: p.haptics,
                activeThumbColor: ArenaPalette.lime,
                title: const Text('Haptics'),
                subtitle: const Text('Tap feedback on answers', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setHaptics(v),
              ),
              SwitchListTile(
                value: p.reduceMotion,
                activeThumbColor: ArenaPalette.electric,
                title: const Text('Reduce motion'),
                subtitle: const Text('Calmer arena. Less pulse and shake.', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setReduceMotion(v),
              ),
              SwitchListTile(
                value: p.skipCountdown,
                activeThumbColor: ArenaPalette.gold,
                title: const Text('Skip 3-2-1'),
                subtitle: const Text('Jump straight into the rush.', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setSkipCountdown(v),
              ),
              SwitchListTile(
                value: p.colorblind,
                activeThumbColor: ArenaPalette.cyan,
                title: const Text('Color-assist pads'),
                subtitle: const Text('Higher-contrast answer colors.', style: TextStyle(color: ArenaPalette.mute)),
                onChanged: (v) => store.setColorblind(v),
              ),
              const SizedBox(height: 8),
              const Text('PINNED MODE', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in const ['', 'rush', 'practice', 'reaction', 'memory', 'accuracy', 'duel', 'daily'])
                    ChoiceChip(
                      label: Text(e.isEmpty ? 'NONE' : e.toUpperCase()),
                      selected: p.pinnedMode == e,
                      selectedColor: ArenaPalette.cyan.withValues(alpha: 0.3),
                      onSelected: (_) => store.setPinnedMode(e),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('1v1 CPU SKILL', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in const [(0, 'ROOKIE'), (1, 'RIVAL'), (2, 'ACE')])
                    ChoiceChip(
                      label: Text(e.$2),
                      selected: p.cpuSkill == e.$1,
                      selectedColor: ArenaPalette.magenta.withValues(alpha: 0.3),
                      onSelected: (_) => store.setCpuSkill(e.$1),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('ARENA ACCENT', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in const ['cyan', 'magenta', 'gold', 'lime', 'electric'])
                    ChoiceChip(
                      label: Text(e.toUpperCase()),
                      selected: p.accent == e,
                      selectedColor: ArenaPalette.named(e).withValues(alpha: 0.35),
                      onSelected: (_) => store.setAccent(e),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('GRAPHICS', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: GraphicsQuality.values.map((q) {
                  final on = p.quality == q;
                  return ChoiceChip(
                    label: Text(q.name.toUpperCase()),
                    selected: on,
                    selectedColor: ArenaPalette.cyan.withValues(alpha: 0.3),
                    onSelected: (_) => store.setQuality(q),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              HoloPanel(
                accent: ArenaPalette.gold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MINDARENA PLUS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    const Text('No ads. Exclusive gold skin. +15% XP. Cosmetics stay cosmetic.', style: TextStyle(color: ArenaPalette.mute, height: 1.35)),
                    const SizedBox(height: 10),
                    NeonButton(
                      label: p.isPremium ? 'PLUS ACTIVE' : 'ACTIVATE PLUS (DEMO)',
                      color: ArenaPalette.gold,
                      onTap: p.isPremium ? null : () => store.activatePlus(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!p.isPremium)
                NeonButton(
                  label: 'WATCH AD FOR 2× XP',
                  color: ArenaPalette.magenta,
                  onTap: () => showRewardedPreview(context),
                ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'HOW TO PLAY',
                color: ArenaPalette.cyan,
                icon: Icons.menu_book,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToScreen())),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'QUESTION PIPELINE',
                color: ArenaPalette.cyan,
                icon: Icons.fact_check,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PipelineScreen())),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'COPY LOCAL BACKUP',
                color: ArenaPalette.electric,
                icon: Icons.file_upload_outlined,
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: store.exportBackup()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile backup copied. Password is not included.')));
                },
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'RESTORE BACKUP',
                color: ArenaPalette.electric,
                icon: Icons.file_download_outlined,
                onTap: () async {
                  final c = TextEditingController();
                  final raw = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: ArenaPalette.deepNavy,
                      title: const Text('RESTORE BACKUP'),
                      content: TextField(controller: c, maxLines: 6, decoration: const InputDecoration(hintText: 'Paste backup JSON')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                        TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('RESTORE')),
                      ],
                    ),
                  );
                  c.dispose();
                  if (raw == null || raw.trim().isEmpty || !context.mounted) return;
                  final err = await store.importBackup(raw);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Arena identity restored.')));
                },
              ),
              const SizedBox(height: 12),
              NeonButton(label: 'PRIVACY & TERMS', color: ArenaPalette.electric, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen()))),
              const SizedBox(height: 12),
              NeonButton(
                label: 'LOG OUT',
                color: ArenaPalette.danger,
                onTap: () async {
                  await store.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const GateScreen()), (_) => false);
                },
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'DELETE LOCAL ACCOUNT',
                color: ArenaPalette.danger,
                onTap: () async {
                  await store.deleteAccount();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const GateScreen()), (_) => false);
                },
              ),
              const SizedBox(height: 16),
              const HoloPanel(
                child: Text(
                  'Live Firebase Auth, Firestore, Crashlytics, and Cloud Messaging plug in when you add a Firebase project. This build already signs match scores locally so a server can reject impossible boards later.',
                  style: TextStyle(color: ArenaPalette.mute, height: 1.45, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
