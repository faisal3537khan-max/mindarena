# Architecture

MindArena is a single Flutter app. There is no second navigation stack and no second store. Screens talk to `GameStore`. Persistence is local JSON.

## Boot

1. `main.dart` locks portrait and launches `MindArenaApp`.
2. `app.dart` creates `AudioService` + `GameStore`, calls `load()`, and wraps the tree in `ChangeNotifierProvider`.
3. `MediaQuery.disableAnimations` follows `player.reduceMotion`.
4. Until `ready`, a boot splash is shown. Then `SplashScreen` → `GateScreen` (first run) or `HomeScreen` (returning player).

## Source of truth

`lib/services/game_store.dart` owns:

- `PlayerProfile` (XP, coins, streaks, settings, history, notebook, friends)
- Match application (`applyMatch`) — XP, coins, achievements, season/weekly points, signed score
- Daily missions, QOTD, shop, Plus demo, backups
- Leaderboard assembly (player score mixed with seeded rivals)
- Question pipeline drafts

Screens must not invent a parallel profile. Practice mode (`mode == 'practice'`) is half XP and does not update ranked best, season, weekly, university, login streak, or wins.

## Persistence keys

| Key | Contents |
| --- | --- |
| `mindarena_profile_v1` | Active `PlayerProfile` JSON |
| `mindarena_accounts_v1` | Local email accounts (password hash stored locally; backups strip it) |
| `mindarena_pipeline_v1` | Question drafts. Never auto-published |

Scores are capped (`answered * 220 + 80`) and hashed into `lastSignature` so a future server can reject impossible boards. `firebase/firestore.rules` encodes that intent.

## Match flow

```
Rush / duel / mini-game
  → collect ReviewItem + timings
  → GameStore.applyMatch(...)
  → ResultsScreen (reveal, rematch, copy challenge, review)
```

Ghost scores compare against the last history row of the same mode. Misses append to a 20-item notebook and can be drilled as a practice rush when four bank prompts match.

## UI kit

`lib/core/widgets/arena_kit.dart` — holographic panels, neon buttons, XP bar, particle background, leave-arena confirm.

`lib/core/palette.dart` — cyan / magenta / gold / lime / electric. `ArenaPalette.named` is the player accent. Color-assist pads swap to a higher-contrast set.

## Audio

`AudioService` plays `assets/sfx/*.wav` (click, correct, wrong, countdown, go, levelup, victory, reward, looping music). Volume 0–100 lives on the profile. `playSfx` is not called inside `setState`.

## Content

`lib/data/question_bank.dart` — unique IDs (`b1`, `m16`, `t22`, …). Math Rush and Word Master also generate live items. Pipeline drafts are duplicate-checked against the bank and never go live by themselves.

## Screens (`lib/screens/`)

| File | Role |
| --- | --- |
| `splash_screen.dart` | Brand + tap-to-skip; guest gate |
| `auth_screen.dart` | Local create / login |
| `home_screen.dart` | Hub, dock, QOTD, continue, missions |
| `rush_screen.dart` | Timed quiz, 3-2-1-GO, pause, keys 1–4 |
| `results_screen.dart` | Score reveal, rematch, challenge copy |
| `modes_screen.dart` | Ten arenas |
| `duel_screen.dart` | 8-question CPU 1v1 |
| `reaction_screen.dart` / `memory_screen.dart` / `accuracy_screen.dart` | Mini-games |
| `daily_screen.dart` / `tournament_screen.dart` / `missions_screen.dart` / `season_screen.dart` | Daily loop |
| `leaderboard_screen.dart` | Global, country, campus, season, weekly |
| `profile_screen.dart` / `avatar_screen.dart` / `shop_screen.dart` | Identity + cosmetics |
| `settings_screen.dart` | Audio, motion, accent, backup |
| `friends_screen.dart` | Arena codes |
| `review_screen.dart` | Last run + miss notebook |
| `pipeline_screen.dart` | Draft questions + flags |
| `stats_screen.dart` / `achievements_screen.dart` / `how_to_screen.dart` | Meta |

`continuePlay` in `home_screen.dart` resumes the last (or pinned) mode. History rematch uses the same helper.

## What this build is not

- Not Unity. “3D” is CustomPainter, Transform, and particles.
- Not live matchmaking. 1v1 is CPU with Rookie / Rival / Ace hit chance.
- Not production Auth, Firestore, FCM, AdMob, or Crashlytics. Those plug in when a Firebase project and `google-services.json` exist.
