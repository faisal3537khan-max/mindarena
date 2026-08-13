# MindArena

**Play for fun. Challenge your brain. Compete with everyone.**

MindArena is a cross-platform competitive mini-game platform built in Flutter. It is a finished product loop — identity, match, results, rank, season — not a quiz list with a score on top.

Author: **Muhammad Faisal Khan** · CS student, Air University (Lahore)

## What shipped

| Area | Details |
| --- | --- |
| Arenas | Brain, Math, Tech, World, Science, Word, Reaction, Memory, Accuracy, Entertainment |
| Modes | 60-second Rush, Practice, Daily, CPU 1v1, Weekly, Tournament |
| Mini-games | Reaction timing, memory matching, accuracy aim |
| Progression | XP, levels, coins, daily streak, match win streak, streak savers, first-win bonus, weekend coins |
| Seasons | Named season, days left, cosmetic reward track |
| Social | Arena codes, rivals, global / country / university / season / weekly boards |
| Meta | Shop, avatars, achievements, missions, miss notebook, question pipeline |
| Access | Guest play, local accounts, reduce-motion, color-assist pads, graphics quality, volume sliders |

Cosmetics never change questions, timers, or ranks.

## Screenshots

Run the app and capture Home, Rush, and Results for LinkedIn / GitHub. No stock art is bundled.

```bash
flutter run
```

## Run locally

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) 3.41+ (Dart 3.11).

```bash
git clone https://github.com/REPLACE_GITHUB_USER/mindarena.git
cd mindarena
flutter pub get
flutter run
```

Targets: Android (`com.mindarena.mindarena`), Windows, Chrome, iOS (Xcode).

```bash
flutter run -d chrome
flutter test
flutter analyze
```

Generate sound effects if `assets/sfx/` is empty:

```bash
python tool/gen_sfx.py
```

## Architecture (short)

```
lib/
  main.dart                 orientation + system UI
  app.dart                  Provider boot, reduce-motion, splash
  core/                     palette, theme, ArenaBackground, pads, avatar
  models/models.dart        profile, match, shop, missions, review
  data/                     question bank, math/word generators, catalogs
  services/game_store.dart  single source of truth + persistence
  services/audio_service.dart
  screens/                  one screen per product surface
```

- **State:** `provider` — `GameStore` is the only store.
- **Persistence:** `shared_preferences` JSON (`mindarena_profile_v1`, `mindarena_accounts_v1`, `mindarena_pipeline_v1`).
- **Identity:** local guest / email sessions. Not production Firebase Auth.
- **Live backend:** `firebase/firestore.rules` is ready; the client still runs fully offline.

Full write-up: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)  
How to play: [docs/GAMEPLAY.md](docs/GAMEPLAY.md)  
Career / LinkedIn paste kit: [career/README.md](career/README.md)

## Stack

Flutter, Dart, Provider, SharedPreferences, audioplayers, flutter_animate, confetti, google_fonts, uuid, intl.

## License

MIT — see [LICENSE](LICENSE).
