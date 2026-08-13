import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/palette.dart';
import '../core/widgets/arena_kit.dart';
import '../core/widgets/avatar_view.dart';
import '../models/models.dart';
import '../services/game_store.dart';
import 'accuracy_screen.dart';
import 'auth_screen.dart';
import 'daily_screen.dart';
import 'duel_screen.dart';
import 'friends_screen.dart';
import 'how_to_screen.dart';
import 'leaderboard_screen.dart';
import 'memory_screen.dart';
import 'missions_screen.dart';
import 'modes_screen.dart';
import 'profile_screen.dart';
import 'reaction_screen.dart';
import 'review_screen.dart';
import 'rush_screen.dart';
import 'season_screen.dart';
import 'shop_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final p = store.player;
    return Stack(
      children: [
        Scaffold(
      body: ArenaBackground(
        quality: p.quality,
        accent: ArenaPalette.named(p.accent),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const GlowText('MINDARENA', size: 28),
              const SizedBox(height: 6),
              Text(
                'Welcome back, ${p.username}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.mute, letterSpacing: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                '🏆 Rank #${store.globalRankFor(p.bestScore)}   ·   ${p.coins} coins${p.doubleXpLive ? '   ·   2× XP' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w800, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'SEASON ${store.seasonName}  •  ${store.seasonDaysLeft}d left${store.missionsReady > 0 ? '  •  ${store.missionsReady} mission loot' : ''}${store.weekendEvent ? '  •  WEEKEND BONUS COINS' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ArenaPalette.mute, fontSize: 11, letterSpacing: 0.4),
              ),
              if (p.history.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('FORM  ', style: TextStyle(color: ArenaPalette.mute, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                    for (final m in p.history.take(5).toList().reversed)
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.won ? ArenaPalette.lime : ArenaPalette.danger,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: const Text('OFFLINE ARENA READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                    backgroundColor: ArenaPalette.panel,
                    side: BorderSide(color: ArenaPalette.lime.withValues(alpha: 0.45)),
                    avatar: const Icon(Icons.wifi_off, size: 14, color: ArenaPalette.lime),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HoloPanel(
                child: Row(
                  children: [
                    AvatarView(config: p.avatar, size: 86),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LEVEL ${p.level}  •  ${p.rankTitle}', style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                          const SizedBox(height: 8),
                          XpBar(progress: p.levelProgress),
                          const SizedBox(height: 6),
                          Text('${p.xpIntoLevel} / ${p.xpForLevel(p.level)} XP', style: const TextStyle(color: ArenaPalette.mute, fontSize: 11)),
                          const SizedBox(height: 8),
                          Text('🔥 ${p.streak} DAY STREAK${p.streakSavers > 0 ? '  •  ${p.streakSavers} saver' : ''}', style: const TextStyle(color: ArenaPalette.gold, fontWeight: FontWeight.w700)),
                          if (p.matchWinStreak > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '⚔️ ${p.matchWinStreak} WIN STREAK  •  BEST ${p.bestWinStreak}',
                              style: const TextStyle(color: ArenaPalette.magenta, fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '🎓 ${p.university}  •  ${store.universityTotals()[p.university] ?? p.universityPoints} campus pts',
                            style: const TextStyle(color: ArenaPalette.mute, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.05),
              const SizedBox(height: 16),
              HoloPanel(
                accent: ArenaPalette.named(p.accent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.xpTodayLive >= 400
                          ? 'DAILY XP  ${store.xpTodayLive}  •  GOAL HIT'
                          : 'DAILY XP  ${store.xpTodayLive} / 400',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12, color: ArenaPalette.gold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (store.xpTodayLive / 400).clamp(0, 1),
                      color: ArenaPalette.gold,
                      backgroundColor: Colors.white10,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _QuestionOfDay(),
              const SizedBox(height: 22),
              _PlayNow(
                onTap: () {
                  store.audio.playSfx('click');
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RushScreen()));
                },
                pulse: !p.reduceMotion,
              ).animate().fadeIn(delay: p.reduceMotion ? 0.ms : 120.ms),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final c in GameCategory.values.where((e) => e.isQuiz))
                    ActionChip(
                      avatar: Icon(c.icon, size: 16, color: c.accent),
                      label: Text(c.title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                      backgroundColor: ArenaPalette.panel,
                      side: BorderSide(color: c.accent.withValues(alpha: 0.45)),
                      onPressed: () {
                        store.audio.playSfx('click');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RushScreen(category: c, title: c.title.toUpperCase()),
                          ),
                        );
                      },
                    ),
                ],
              ),
              if (p.provider == AuthProviderType.guest && p.bestScore >= 300) ...[
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.save_alt,
                  title: 'SAVE YOUR SCORE',
                  subtitle: 'Guest PB ${p.bestScore}. Create an identity so it stays on the board.',
                  color: ArenaPalette.magenta,
                  onTap: () {
                    store.audio.playSfx('click');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                  },
                ),
              ],
              if (store.canClaimDaily) ...[
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.local_fire_department,
                  title: 'CLAIM STREAK LOOT',
                  subtitle: 'Day ${((p.streak == 0 ? 0 : p.streak - 1) % 7) + 1} is waiting.',
                  color: ArenaPalette.gold,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyScreen())),
                ),
              ],
              if (store.todayMissions.any((m) => !m.done)) ...[
                const SizedBox(height: 2),
                _Tile(
                  icon: Icons.flag_outlined,
                  title: 'NEXT MISSION',
                  subtitle: store.todayMissions.firstWhere((m) => !m.done).title,
                  color: ArenaPalette.gold,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MissionsScreen())),
                ),
              ],
              if (p.notebook.isNotEmpty) ...[
                const SizedBox(height: 2),
                _Tile(
                  icon: Icons.menu_book,
                  title: 'DRILL YOUR MISSES',
                  subtitle: '${p.notebook.length} in the notebook. Turn them into a practice rush.',
                  color: ArenaPalette.electric,
                  onTap: () {
                    store.audio.playSfx('click');
                    final drill = store.notebookDrill();
                    if (drill.length < 4) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotebookScreen()));
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RushScreen(mode: 'practice', title: 'MISS DRILL', seed: drill),
                      ),
                    );
                  },
                ),
              ],
              if (p.pinnedMode.isNotEmpty) ...[
                const SizedBox(height: 10),
                _Tile(
                  icon: Icons.push_pin,
                  title: 'PINNED • ${p.pinnedMode.toUpperCase()}',
                  subtitle: 'Your shortcut. Change it in Settings.',
                  color: ArenaPalette.gold,
                  onTap: () {
                    store.audio.playSfx('click');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => continuePlay(p, p.pinnedMode)));
                  },
                ),
              ],
              if (p.lastMode.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.replay,
                  title: 'CONTINUE',
                  subtitle: 'Jump back into ${p.lastMode.toUpperCase()}.',
                  color: ArenaPalette.cyan,
                  onTap: () {
                    store.audio.playSfx('click');
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => continuePlay(p)));
                  },
                ),
              ],
              const SizedBox(height: 6),
              _Tile(
                icon: Icons.fitness_center,
                title: 'PRACTICE RUSH',
                subtitle: 'Half XP. Does not update ranked best or season.',
                color: ArenaPalette.electric,
                onTap: () {
                  store.audio.playSfx('click');
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RushScreen(mode: 'practice', title: 'PRACTICE RUSH')));
                },
              ),
              _Tile(
                icon: Icons.flag_outlined,
                title: 'DAILY MISSIONS',
                subtitle: store.missionsReady > 0 ? '${store.missionsReady} ready to claim' : 'Three short jobs. Extra coins.',
                color: ArenaPalette.gold,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MissionsScreen())),
              ),
              _Tile(
                icon: Icons.wb_sunny_outlined,
                title: 'DAILY CHALLENGE',
                subtitle: store.canDailyChallenge
                    ? 'Today: ${store.dailyCategory.title}. Extra XP.'
                    : 'Already conquered today.',
                color: ArenaPalette.gold,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyScreen())),
              ),
              _Tile(
                icon: Icons.leaderboard,
                title: 'LEADERBOARD',
                subtitle: 'Global • Country • University',
                color: ArenaPalette.magenta,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              ),
              _Tile(
                icon: Icons.sports_esports,
                title: 'GAME MODES',
                subtitle: 'Ten arenas. Pick your battlefield.',
                color: ArenaPalette.lime,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ModesScreen())),
              ),
              _Tile(
                icon: Icons.person,
                title: 'PROFILE',
                subtitle: 'Avatar, stats, settings, identity',
                color: ArenaPalette.cyan,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
              _Tile(
                icon: Icons.storefront,
                title: 'COSMETIC SHOP',
                subtitle: 'Looks only. Never pay-to-win.',
                color: ArenaPalette.gold,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopScreen())),
              ),
              _Tile(
                icon: Icons.handshake,
                title: 'RIVALS',
                subtitle: 'Arena code ${store.arenaCode}. Challenge a friend.',
                color: ArenaPalette.magenta,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FriendsScreen())),
              ),
              _Tile(
                icon: Icons.people_alt,
                title: 'CHALLENGE A RIVAL',
                subtitle: 'Same questions. First mind to fire.',
                color: ArenaPalette.magenta,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DuelScreen())),
              ),
              _Tile(
                icon: Icons.emoji_events_outlined,
                title: 'SEASON TRACK',
                subtitle: '${p.seasonPoints} pts this season. Cosmetic loot only.',
                color: ArenaPalette.gold,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SeasonScreen())),
              ),
              _Tile(
                icon: Icons.menu_book,
                title: 'HOW TO PLAY',
                subtitle: 'The arena in eight beats.',
                color: ArenaPalette.cyan,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HowToScreen())),
              ),
              _Tile(
                icon: Icons.insights,
                title: 'ARENA STATS',
                subtitle: 'Accuracy, season points, favorite mode',
                color: ArenaPalette.electric,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xEE0B1024),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _HomeDock(
              icon: Icons.bolt,
              label: 'PLAY',
              color: ArenaPalette.cyan,
              onTap: () {
                store.audio.playSfx('click');
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RushScreen()));
              },
            ),
            _HomeDock(
              icon: Icons.sports_esports,
              label: 'MODES',
              color: ArenaPalette.lime,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ModesScreen())),
            ),
            _HomeDock(
              icon: Icons.leaderboard,
              label: 'BOARD',
              color: ArenaPalette.gold,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
            ),
            _HomeDock(
              icon: Icons.person,
              label: 'ME',
              color: ArenaPalette.magenta,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ],
        ),
      ),
        ),
        if (!p.seenTips) _FirstRunTips(onDone: () => store.dismissTips()),
      ],
    );
  }
}

class _HomeDock extends StatelessWidget {
  const _HomeDock({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _PlayNow extends StatelessWidget {
  const _PlayNow({required this.onTap, this.pulse = true});
  final VoidCallback onTap;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ArenaPalette.cyan, width: 1.6),
        gradient: LinearGradient(
          colors: [ArenaPalette.cyan.withValues(alpha: 0.28), ArenaPalette.magenta.withValues(alpha: 0.16), const Color(0xFF101428)],
        ),
        boxShadow: [BoxShadow(color: ArenaPalette.cyan.withValues(alpha: 0.28), blurRadius: 24)],
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡  PLAY NOW', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 2)),
            SizedBox(height: 4),
            Text('60-SECOND RUSH', style: TextStyle(color: ArenaPalette.mute, letterSpacing: 3, fontSize: 12)),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: pulse
          ? box.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.035, 1.035), duration: 900.ms)
          : box,
    );
  }
}

class _QuestionOfDay extends StatefulWidget {
  const _QuestionOfDay();

  @override
  State<_QuestionOfDay> createState() => _QuestionOfDayState();
}

class _QuestionOfDayState extends State<_QuestionOfDay> {
  int? _picked;
  bool? _ok;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GameStore>();
    final q = store.questionOfTheDay;
    final locked = !store.canAnswerQotd;
    return HoloPanel(
      accent: ArenaPalette.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('QUESTION OF THE DAY', style: TextStyle(letterSpacing: 1.4, fontSize: 11, fontWeight: FontWeight.w900, color: ArenaPalette.gold)),
          const SizedBox(height: 8),
          Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35)),
          const SizedBox(height: 10),
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: locked
                    ? null
                    : () async {
                        final ok = await store.answerQotd(i);
                        if (!mounted) return;
                        setState(() {
                          _picked = i;
                          _ok = ok;
                        });
                        store.audio.playSfx(ok ? 'correct' : 'wrong');
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _picked == i
                          ? (_ok == true ? ArenaPalette.lime : ArenaPalette.danger)
                          : Colors.white12,
                    ),
                    color: ArenaPalette.panel,
                  ),
                  child: Text(q.options[i], style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          if (locked)
            Text(
              _ok == true
                  ? 'Nice. +20 coins, +25 XP. Back tomorrow.'
                  : _ok == false
                      ? 'Not this time. ${q.explanation}'
                      : 'Already answered today. ${q.explanation}',
              style: const TextStyle(color: ArenaPalette.mute, fontSize: 12, height: 1.35),
            ),
        ],
      ),
    );
  }
}

class _FirstRunTips extends StatelessWidget {
  const _FirstRunTips({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: HoloPanel(
              accent: ArenaPalette.cyan,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GlowText('ARENA TIPS', size: 22),
                  const SizedBox(height: 12),
                  const Text('⚡ PLAY NOW launches a 60-second rush with a 3-2-1-GO countdown.', textAlign: TextAlign.center, style: TextStyle(height: 1.4)),
                  const SizedBox(height: 8),
                  const Text('💡 Misses pause the clock for a Did you know? — then you fire again.', textAlign: TextAlign.center, style: TextStyle(height: 1.4)),
                  const SizedBox(height: 8),
                  const Text('🎯 Practice never updates your ranked best, season, or weekly board.', textAlign: TextAlign.center, style: TextStyle(height: 1.4)),
                  const SizedBox(height: 16),
                  NeonButton(label: 'GOT IT — LET ME PLAY', onTap: onDone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: ArenaPalette.panel,
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.6)),
        subtitle: Text(subtitle, style: const TextStyle(color: ArenaPalette.mute, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: color),
      ),
    );
  }
}

Widget continuePlay(PlayerProfile p, [String? mode]) {
  switch (mode ?? p.lastMode) {
    case 'practice':
      return const RushScreen(mode: 'practice', title: 'PRACTICE RUSH');
    case 'reaction':
      return const ReactionScreen();
    case 'memory':
      return const MemoryScreen();
    case 'accuracy':
      return const AccuracyScreen();
    case 'duel':
      return const DuelScreen();
    case 'weekly':
      return const RushScreen(mode: 'weekly', title: 'WEEKLY CHAMPIONSHIP', seconds: 90);
    case 'tournament':
      return const RushScreen(mode: 'tournament', title: 'DAILY TOURNAMENT', seconds: 75);
    case 'daily':
      final cats = GameCategory.values.where((e) => e.name == p.lastCategory);
      return RushScreen(mode: 'daily', title: 'DAILY CHALLENGE', category: cats.isEmpty ? null : cats.first);
    default:
      final cats = GameCategory.values.where((e) => e.name == p.lastCategory);
      if (cats.isNotEmpty && cats.first.isQuiz) {
        return RushScreen(category: cats.first, title: cats.first.title.toUpperCase());
      }
      return const RushScreen();
  }
}

class SaveScoreBanner {
  static void maybeShow(BuildContext context) {
    final store = context.read<GameStore>();
    if (store.player.provider != AuthProviderType.guest) return;
    if (store.player.totalGames != 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: ArenaPalette.deepNavy,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlowText('SAVE YOUR SCORE', size: 20),
              const SizedBox(height: 8),
              const Text('Create an identity so this run lives on the board.', textAlign: TextAlign.center, style: TextStyle(color: ArenaPalette.mute)),
              const SizedBox(height: 16),
              NeonButton(
                label: 'CREATE ACCOUNT',
                color: ArenaPalette.magenta,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
              ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('LATER', style: TextStyle(color: ArenaPalette.mute))),
            ],
          ),
        ),
      );
    });
  }
}
