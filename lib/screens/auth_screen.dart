import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool login = false;
  final user = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  String? error;
  bool busy = false;

  @override
  void dispose() {
    user.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ArenaPalette.mute, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF12182F),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ArenaPalette.cyan.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ArenaPalette.cyan),
        ),
      );

  Future<void> _submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    final store = context.read<GameStore>();
    final msg = login
        ? await store.login(email.text, pass.text)
        : await store.register(username: user.text, email: email.text, password: pass.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (msg != null) {
      setState(() => error = msg);
      return;
    }
    await store.audio.playSfx('levelup');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    return Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const GlowText('ARENA IDENTITY', size: 22),
              const SizedBox(height: 8),
              Text(
                login ? 'Welcome back, Challenger.' : 'Save your score. Own your legend.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.mute),
              ),
              const SizedBox(height: 24),
              if (!login) ...[
                TextField(controller: user, decoration: _dec('Username'), style: const TextStyle(color: ArenaPalette.text)),
                const SizedBox(height: 12),
              ],
              TextField(controller: email, decoration: _dec('Email'), keyboardType: TextInputType.emailAddress, style: const TextStyle(color: ArenaPalette.text)),
              const SizedBox(height: 12),
              TextField(controller: pass, decoration: _dec('Password'), obscureText: true, style: const TextStyle(color: ArenaPalette.text)),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.danger)),
              ],
              const SizedBox(height: 20),
              NeonButton(
                label: busy ? 'SYNCING...' : (login ? 'SIGN IN' : 'CREATE ACCOUNT'),
                onTap: busy ? null : _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => login = !login),
                child: Text(login ? 'Need an identity? Create account' : 'Already in the arena? Sign in', style: const TextStyle(color: ArenaPalette.cyan)),
              ),
              const SizedBox(height: 8),
              NeonButton(
                label: 'CONTINUE WITH GOOGLE',
                color: ArenaPalette.lime,
                icon: Icons.g_mobiledata,
                onTap: () async {
                  await store.quickProvider(AuthProviderType.google);
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
                },
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'CONTINUE WITH APPLE',
                color: ArenaPalette.text,
                icon: Icons.apple,
                onTap: () async {
                  await store.quickProvider(AuthProviderType.apple);
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
