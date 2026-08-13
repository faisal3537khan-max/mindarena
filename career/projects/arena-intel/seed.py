#!/usr/bin/env python3
"""Create arena.db and load a realistic competitive dataset."""

from __future__ import annotations

import random
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB = ROOT / "arena.db"
SCHEMA = (ROOT / "schema.sql").read_text(encoding="utf-8")

COUNTRIES = ["Pakistan", "UAE", "UK", "Germany", "Canada", "USA"]
UNI = ["NUST", "FAST-NUCES", "Independent", "LUMS", "UET"]
MODES = ["rush", "duel", "tournament", "daily", "reaction"]
USERS = [
    ("faisal", "Pakistan", "Independent"),
    ("aisha", "Pakistan", "NUST"),
    ("omar", "UAE", "Independent"),
    ("nora", "UK", "Independent"),
    ("lars", "Germany", "Independent"),
    ("priya", "Canada", "Independent"),
    ("kenji", "USA", "Independent"),
    ("hina", "Pakistan", "FAST-NUCES"),
]


def main() -> None:
    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    con.executescript(SCHEMA)
    rng = random.Random(7)

    cats = [
        ("brain", "Brain Arena"),
        ("math", "Math Rush"),
        ("tech", "Tech Battle"),
        ("world", "World Challenge"),
        ("science", "Science Lab"),
    ]
    con.executemany("INSERT INTO categories(slug, title) VALUES (?, ?)", cats)

    start = datetime(2026, 6, 1)
    con.execute(
        "INSERT INTO seasons(name, starts_on, ends_on) VALUES (?, ?, ?)",
        ("Season 01 — Neon Circuit", start.date().isoformat(), "2026-08-31"),
    )

    for name, country, uni in USERS:
        con.execute(
            "INSERT INTO players(username, country, university) VALUES (?, ?, ?)",
            (name, country, uni),
        )

    player_ids = [r[0] for r in con.execute("SELECT id FROM players")]
    cat_ids = [r[0] for r in con.execute("SELECT id FROM categories")]

    for pid in player_ids:
        skill = 0.45 + (pid * 0.04)
        for i in range(18):
            when = start + timedelta(days=rng.randint(0, 60), hours=rng.randint(0, 23))
            answers = []
            for _ in range(8):
                cid = rng.choice(cat_ids)
                correct = rng.random() < skill
                ms = rng.randint(700, 4200)
                answers.append((cid, int(correct), ms))
            won = sum(a[1] for a in answers) >= 5
            score = sum((1200 - min(a[2], 1199)) // 10 + (80 if a[1] else 0) for a in answers)
            cur = con.execute(
                "INSERT INTO matches(player_id, season_id, mode, score, won, played_at) VALUES (?,?,?,?,?,?)",
                (pid, 1, rng.choice(MODES), score, int(won), when.isoformat(sep=" ")),
            )
            mid = cur.lastrowid
            con.executemany(
                "INSERT INTO match_answers(match_id, category_id, correct, latency_ms) VALUES (?,?,?,?)",
                [(mid, *row) for row in answers],
            )

    con.commit()
    n = con.execute("SELECT COUNT(*) FROM matches").fetchone()[0]
    con.close()
    print(f"Seeded {DB.name} with {n} matches.")


if __name__ == "__main__":
    main()
