import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../core/widgets/avatar_view.dart';
import '../services/game_store.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final a = store.player.avatar;
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
                  const Expanded(child: GlowText('YOUR CHARACTER', size: 16)),
                ],
              ),
              AvatarView(config: a, size: 190),
              const SizedBox(height: 8),
              Text('Unlocked: ${store.player.unlocked.join(', ')}', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.mute, fontSize: 11)),
              const SizedBox(height: 12),
              _row('Face preset', a.preset, 6, (v) => store.setAvatar(a.copyWith(preset: v))),
              _row('Hair style', a.hair, 4, (v) => store.setAvatar(a.copyWith(hair: v))),
              _row('Hair color', a.hairColor, 6, (v) => store.setAvatar(a.copyWith(hairColor: v))),
              _row('Outfit', a.outfit, 6, (v) => store.setAvatar(a.copyWith(outfit: v))),
              _row('Shoes', a.shoes, 6, (v) => store.setAvatar(a.copyWith(shoes: v))),
              _row('Glasses', a.glasses, 3, (v) => store.setAvatar(a.copyWith(glasses: v))),
              _row('Hat', a.hat, 3, (v) => store.setAvatar(a.copyWith(hat: v))),
              _row('Accessory', a.accessory, 3, (v) => store.setAvatar(a.copyWith(accessory: v))),
              _row('Victory pose', a.pose, 3, (v) => store.setAvatar(a.copyWith(pose: v))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, int value, int max, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HoloPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            IconButton(onPressed: () => onChanged((value - 1 + max) % max), icon: const Icon(Icons.chevron_left, color: ArenaPalette.cyan)),
            Text('${value + 1}/$max', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800)),
            IconButton(onPressed: () => onChanged((value + 1) % max), icon: const Icon(Icons.chevron_right, color: ArenaPalette.cyan)),
          ],
        ),
      ),
    );
  }
}
