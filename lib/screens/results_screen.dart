import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../core/widgets/avatar_view.dart';
import '../data/game_content.dart';
import '../models/models.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../services/game_store.dart';
import 'duel_screen.dart';
import 'review_screen.dart';
import 'shop_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.result, required this.replay});

  final MatchResult result;
  final Widget Function() replay;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final ConfettiController _confetti;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = context.read<GameStore>();
      final audio = store.audio;
      await audio.playSfx('victory');
      if (!store.player.reduceMotion) _confetti.play();
      for (var i = 1; i <= 5; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        if (_shown >= 5) break;
        setState(() => _shown = i);
        if (i == 4 && widget.result.levelAfter > widget.result.levelBefore) {
          audio.playSfx('levelup');
        }
        if (i == 5 && widget.result.rewardId != null) {
          audio.playSfx('reward');
        }
      }
      if (mounted) SaveScoreBanner.maybeShow(context);
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final r = widget.result;
    final leveled = r.levelAfter > r.levelBefore;
    String rewardName = r.rewardId?.replaceAll('_', ' ').toUpperCase() ?? '';
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyR): () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.replay()));
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
      body: ArenaBackground(
        quality: store.player.quality,
        accent: ArenaPalette.gold,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [ArenaPalette.cyan, ArenaPalette.magenta, ArenaPalette.gold, ArenaPalette.lime],
              ),
            ),
            SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _shown >= 5 ? null : () => setState(() => _shown = 5),
                child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const GlowText('🎉 MATCH COMPLETE', size: 18, color: ArenaPalette.gold),
                  if (_shown < 5)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Text('TAP TO SKIP REVEAL', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.mute, letterSpacing: 1.6, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  const SizedBox(height: 8),
                  AvatarView(config: store.player.avatar, size: 130, celebrate: true).animate().scale(),
                  const SizedBox(height: 8),
                  GlowText('${r.score}', size: 56, color: ArenaPalette.cyan),
                  if (r.prevScore > 0)
                    Text(
                      r.scoreDelta >= 0 ? '▲ +${r.scoreDelta} vs last run (${r.prevScore})' : '▼ ${r.scoreDelta} vs last run (${r.prevScore})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: r.scoreDelta >= 0 ? ArenaPalette.lime : ArenaPalette.danger,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  if (r.mode == 'practice')
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('PRACTICE RUN — not ranked', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.gold, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                    ),
                  if (r.personalBest)
                    const Text('NEW PERSONAL BEST', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.gold, letterSpacing: 2, fontWeight: FontWeight.w800)),
                  if (store.firstWinBonus)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('☀️ FIRST WIN OF THE DAY  +40 XP  +30 COINS', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.lime, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                    ),
                  if (r.won && store.player.matchWinStreak >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '⚔️ ${store.player.matchWinStreak} MATCH WIN STREAK',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                  if (r.fieldSize > 0) ...[
                    const SizedBox(height: 10),
                    HoloPanel(
                      accent: ArenaPalette.gold,
                      child: Text(
                        r.placement > 0 && r.placement <= 10
                            ? '🏆 DAILY FIELD  #${r.placement} / ${r.fieldSize}  •  TOP 10 LOOT'
                            : '🏟️ DAILY FIELD  #${r.placement} / ${r.fieldSize}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_shown >= 1) _stat('⚡ SPEED', '${r.speedPct}%', ArenaPalette.cyan),
                  if (_shown >= 2) _stat('🧠 ACCURACY', '${r.accuracyPct}%', ArenaPalette.lime),
                  if (_shown >= 3) _stat('🔥 STREAK', '${r.bestStreak}', ArenaPalette.magenta),
                  if (_shown >= 3 && r.mode != 'practice') _stat('🏆 RANK', '#${r.rank}', ArenaPalette.gold),
                  if (_shown >= 4 && leveled) ...[
                    const SizedBox(height: 12),
                    HoloPanel(
                      accent: ArenaPalette.gold,
                      child: Column(
                        children: [
                          const GlowText('LEVEL UP!', size: 22, color: ArenaPalette.gold),
                          const SizedBox(height: 6),
                          Text('LEVEL ${r.levelBefore}  →  LEVEL ${r.levelAfter}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          XpBar(progress: store.player.levelProgress),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],
                  if (_shown >= 5 && r.rewardId != null) ...[
                    const SizedBox(height: 12),
                    HoloPanel(
                      accent: ArenaPalette.magenta,
                      child: Column(
                        children: [
                          const Text('🎁 REWARD UNLOCKED', style: TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(rewardName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                  if (store.lastUnlockedAchievement != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '🏅 ${kAchievements.firstWhere((e) => e.id == store.lastUnlockedAchievement).title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w700),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('+${r.xpGained} XP   •   ${r.correct} correct   •   ${r.wrong} missed', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.mute)),
                  if (store.lastSignature.isNotEmpty)
                    Text('SIGNED ${store.lastSignature}', textAlign: TextAlign.center, style: const TextStyle(color: ArenaPalette.mute, fontSize: 10, letterSpacing: 1)),
                  if (store.streakProtected) ...[
                    const SizedBox(height: 8),
                    const Text('🛡️ STREAK SAVER USED', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                  const SizedBox(height: 22),
                  if (store.lastReview.isNotEmpty) ...[
                    NeonButton(
                      label: 'REVIEW ANSWERS',
                      color: ArenaPalette.electric,
                      icon: Icons.fact_check,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewScreen())),
                    ),
                    const SizedBox(height: 10),
                  ],
                  NeonButton(
                    label: 'COPY CHALLENGE',
                    color: ArenaPalette.electric,
                    icon: Icons.copy,
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(
                        text: 'MindArena challenge: I scored ${r.score} in ${r.mode} (${r.accuracyPct}% acc, ${r.correct} correct). Arena code ${store.arenaCode}. Beat me.',
                      ));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge copied with your arena code.')));
                    },
                  ),
                  const SizedBox(height: 10),
                  NeonButton(
                    label: 'REMATCH',
                    icon: Icons.replay,
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.replay()));
                    },
                  ),
                  const SizedBox(height: 10),
                  NeonButton(
                    label: 'LEADERBOARD',
                    color: ArenaPalette.magenta,
                    icon: Icons.leaderboard,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                  ),
                  const SizedBox(height: 10),
                  NeonButton(
                    label: 'CHALLENGE A RIVAL',
                    color: ArenaPalette.magenta,
                    icon: Icons.people_alt,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DuelScreen())),
                  ),
                  const SizedBox(height: 10),
                  if (!store.player.isPremium)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NeonButton(
                        label: 'WATCH AD — 2× XP',
                        color: ArenaPalette.electric,
                        onTap: () => showRewardedPreview(context),
                      ),
                    ),
                  NeonButton(
                    label: 'HOME',
                    color: ArenaPalette.gold,
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false),
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _stat(String k, String v, Color c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HoloPanel(
        accent: c,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: c, fontWeight: FontWeight.w700)),
            Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ).animate().slideX(begin: 0.08).fadeIn(),
    );
  }
}
