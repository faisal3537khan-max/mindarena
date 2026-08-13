import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../core/widgets/avatar_view.dart';
import '../services/game_store.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'how_to_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _launch;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _launch = Timer(const Duration(milliseconds: 2400), _go);
  }

  @override
  void dispose() {
    _launch?.cancel();
    super.dispose();
  }

  void _go() {
    if (_left || !mounted) return;
    _left = true;
    _launch?.cancel();
    final store = context.read<GameStore>();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => store.player.hasEntered ? const HomeScreen() : const GateScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final q = store.player.quality;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        child: ArenaBackground(
        quality: q,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlowText('MINDARENA', size: 34, color: ArenaPalette.cyan),
              const SizedBox(height: 10),
              const GlowText('THE ARENA OF MINDS', size: 12, color: ArenaPalette.magenta, weight: FontWeight.w500),
              if (store.player.hasEntered) ...[
                const SizedBox(height: 16),
                GlowText('Welcome back, ${store.player.username}.', size: 14, color: ArenaPalette.gold, weight: FontWeight.w600),
              ],
              const SizedBox(height: 18),
              const Text('TAP TO ENTER', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class GateScreen extends StatelessWidget {
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                AvatarView(config: store.player.avatar, size: 150)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 18),
                const GlowText('READY TO ENTER\nTHE ARENA?', size: 26),
                const SizedBox(height: 8),
                const Text(
                  'Play for fun. Challenge your brain.\nCompete with everyone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ArenaPalette.mute, height: 1.4),
                ),
                const Spacer(),
                NeonButton(
                  label: 'PLAY AS GUEST',
                  icon: Icons.bolt,
                  onTap: () async {
                    await store.audio.playSfx('go');
                    await store.enterAsGuest();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                NeonButton(
                  label: 'CREATE ACCOUNT',
                  color: ArenaPalette.magenta,
                  icon: Icons.person_add_alt,
                  onTap: () {
                    store.audio.playSfx('click');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HowToScreen())),
                  child: const Text('HOW TO PLAY', style: TextStyle(color: ArenaPalette.cyan, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
