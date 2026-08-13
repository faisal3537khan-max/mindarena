import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/game_store.dart';

class MindArenaApp extends StatelessWidget {
  const MindArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final audio = AudioService();
        final store = GameStore(audio);
        store.load();
        return store;
      },
      child: MaterialApp(
        title: 'MindArena',
        debugShowCheckedModeBanner: false,
        theme: buildArenaTheme(),
        builder: (context, child) {
          final reduce = context.watch<GameStore>().player.reduceMotion;
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const _Boot(),
      ),
    );
  }
}

class _Boot extends StatelessWidget {
  const _Boot();

  @override
  Widget build(BuildContext context) {
    final ready = context.watch<GameStore>().ready;
    if (!ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF050510),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MINDARENA',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: 140,
                child: LinearProgressIndicator(color: Color(0xFF00F0FF), backgroundColor: Colors.white10),
              ),
            ],
          ),
        ),
      );
    }
    return const SplashScreen();
  }
}
