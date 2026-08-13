# MindArena

Competitive mini-game platform for Android, iOS, Windows, and web. Built in Flutter.

Ten arenas. Multiple live modes. A player economy, seasons, and a design system that looks like a product — not a classroom demo.

## Why this exists

Most quiz apps are a list of questions and a score. MindArena is a loop: identity → match → results → rank → season rewards. The store, missions, avatars, and leaderboards exist so progression still matters after the first session.

## Product surface

| Area | What shipped |
| --- | --- |
| Arenas | Brain, Math, Tech, World, Science, Word, Reaction, Memory, Accuracy, Entertainment |
| Modes | 60s Rush, Practice, Daily, CPU Duel, Weekly, Tournament |
| Mini-games | Reaction timing, memory grid, accuracy aim |
| Progression | XP, levels, coins, streaks, streak savers, first-win bonus, weekend events |
| Seasons | Named season, countdown, reward track |
| Social | Friends, duels, global / country / university leaderboards |
| Meta | Shop, avatars, achievements, daily rewards, review notebook, question pipeline |
| Access | Guest + local email accounts, reduce-motion, color-blind, quality tiers |

## Architecture

```
lib/
  app.dart              MaterialApp + Provider boot
  core/                 theme, palette, shared widgets
  models/               domain types (profile, match, season, …)
  data/                 question bank + static catalogs
  services/
    game_store.dart     single source of truth + persistence
    audio_service.dart  music / SFX
  screens/              one screen per product surface
```

- **State:** `provider` — `GameStore` extends `ChangeNotifier`.
- **Persistence:** `shared_preferences` JSON snapshots (`mindarena_profile_v1`, accounts, pipeline).
- **Motion:** `flutter_animate` + `MediaQuery.disableAnimations` when the player requests reduced motion.
- **Identity:** local registration/login (not a production auth vendor — called out honestly).

## Run

```bash
flutter pub get
flutter run
```

Web:

```bash
flutter run -d chrome
```

## LinkedIn one-liner

Flutter competitive arena: 10 categories, rush/duel/tournament, seasons, missions, shop, and local persistence — custom design system, Provider, SharedPreferences.
