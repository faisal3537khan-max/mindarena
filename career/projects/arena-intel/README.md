# Arena Intel

Python analytics API for competitive match data. SQLite in third normal form, indexed leaderboards, and SQL that answers product questions — not `SELECT *`.

Stdlib only (`http.server`, `sqlite3`, `json`). No pip.

## Schema

```
players 1──* matches 1──* match_answers *──1 categories
                │
                └── seasons (by played_at window)
```

Indexes:

- `matches(player_id, played_at)`
- `matches(score DESC)`
- `players(country)`
- `match_answers(category_id)`

Views: `v_player_form`, `v_category_skill`, `v_season_standings`.

## Run

```bash
python career/projects/arena-intel/seed.py
python career/projects/arena-intel/server.py
```

Then:

```
GET  http://127.0.0.1:8787/health
GET  http://127.0.0.1:8787/leaderboard?scope=global&limit=10
GET  http://127.0.0.1:8787/players/1/stats
GET  http://127.0.0.1:8787/intel/risk
GET  http://127.0.0.1:8787/intel/categories
POST http://127.0.0.1:8787/matches
```

Example POST body:

```json
{
  "player_id": 1,
  "mode": "rush",
  "score": 820,
  "won": true,
  "answers": [
    {"category_id": 1, "correct": true, "ms": 1400},
    {"category_id": 2, "correct": false, "ms": 3100}
  ]
}
```

## Interview talking points

- Why `match_answers` is a child table (one match, many category rows) instead of a JSON blob.
- Why the leaderboard index is on `score` and why `played_at` still needs its own composite index.
- How `v_player_form` encodes last-5 without application loops.
- Transactions: match + answers commit together or not at all.
