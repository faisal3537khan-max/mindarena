#!/usr/bin/env python3
"""Arena Intel HTTP API — stdlib only."""

from __future__ import annotations

import json
import sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

ROOT = Path(__file__).resolve().parent
DB = ROOT / "arena.db"


def connect() -> sqlite3.Connection:
    if not DB.exists():
        raise SystemExit("Run seed.py first.")
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    return con


def rows(cur) -> list[dict]:
    return [dict(r) for r in cur.fetchall()]


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt: str, *args) -> None:
        print("[%s] " % self.log_date_time_string() + fmt % args)

    def _send(self, code: int, payload) -> None:
        body = json.dumps(payload, default=str).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self) -> None:  # noqa: N802
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        q = parse_qs(parsed.query)
        path = parsed.path.rstrip("/") or "/"
        con = connect()
        try:
            if path == "/health":
                self._send(200, {"ok": True, "service": "arena-intel"})
                return
            if path == "/leaderboard":
                scope = q.get("scope", ["global"])[0]
                limit = int(q.get("limit", ["10"])[0])
                if scope == "country":
                    country = q.get("country", ["Pakistan"])[0]
                    cur = con.execute(
                        """
                        SELECT username, country, best_score, win_rate, matches_played
                        FROM v_player_form
                        WHERE country = ?
                        ORDER BY best_score DESC
                        LIMIT ?
                        """,
                        (country, limit),
                    )
                else:
                    cur = con.execute(
                        """
                        SELECT username, country, best_score, win_rate, matches_played
                        FROM v_player_form
                        ORDER BY best_score DESC
                        LIMIT ?
                        """,
                        (limit,),
                    )
                self._send(200, {"scope": scope, "rows": rows(cur)})
                return
            if path.startswith("/players/") and path.endswith("/stats"):
                pid = int(path.split("/")[2])
                form = con.execute("SELECT * FROM v_player_form WHERE player_id = ?", (pid,)).fetchone()
                if not form:
                    self._send(404, {"error": "player not found"})
                    return
                cats = con.execute(
                    "SELECT category, attempts, accuracy, avg_ms FROM v_category_skill WHERE player_id = ? ORDER BY accuracy DESC",
                    (pid,),
                )
                recent = con.execute(
                    """
                    SELECT mode, score, won, played_at
                    FROM matches WHERE player_id = ?
                    ORDER BY played_at DESC LIMIT 5
                    """,
                    (pid,),
                )
                self._send(
                    200,
                    {"player": dict(form), "categories": rows(cats), "recent": rows(recent)},
                )
                return
            if path == "/intel/categories":
                cur = con.execute(
                    """
                    SELECT c.title, COUNT(*) AS attempts,
                           ROUND(100.0 * SUM(a.correct) / COUNT(*), 1) AS accuracy,
                           ROUND(AVG(a.latency_ms), 0) AS avg_ms
                    FROM match_answers a
                    JOIN categories c ON c.id = a.category_id
                    GROUP BY c.id
                    ORDER BY accuracy DESC
                    """
                )
                self._send(200, {"categories": rows(cur)})
                return
            if path == "/intel/risk":
                cur = con.execute(
                    """
                    SELECT player_id, username, win_rate, matches_played, avg_score
                    FROM v_player_form
                    WHERE matches_played >= 8 AND win_rate BETWEEN 45 AND 58
                    ORDER BY win_rate ASC
                    """
                )
                self._send(
                    200,
                    {
                        "definition": "Players with a mid win-rate and enough volume — streak is statistically fragile.",
                        "rows": rows(cur),
                    },
                )
                return
            self._send(404, {"error": "unknown route"})
        finally:
            con.close()

    def do_POST(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        if parsed.path.rstrip("/") != "/matches":
            self._send(404, {"error": "unknown route"})
            return
        length = int(self.headers.get("Content-Length", "0"))
        body = json.loads(self.rfile.read(length) or b"{}")
        answers = body.get("answers") or []
        con = connect()
        try:
            con.execute("BEGIN")
            cur = con.execute(
                "INSERT INTO matches(player_id, season_id, mode, score, won) VALUES (?,?,?,?,?)",
                (
                    int(body["player_id"]),
                    int(body.get("season_id", 1)),
                    str(body.get("mode", "rush")),
                    int(body["score"]),
                    1 if body.get("won") else 0,
                ),
            )
            mid = cur.lastrowid
            con.executemany(
                "INSERT INTO match_answers(match_id, category_id, correct, latency_ms) VALUES (?,?,?,?)",
                [
                    (mid, int(a["category_id"]), 1 if a.get("correct") else 0, int(a.get("ms", 0)))
                    for a in answers
                ],
            )
            con.commit()
            self._send(201, {"match_id": mid, "answers": len(answers)})
        except Exception as exc:  # noqa: BLE001 — return as JSON to the client
            con.rollback()
            self._send(400, {"error": str(exc)})
        finally:
            con.close()


def main() -> None:
    host, port = "127.0.0.1", 8787
    httpd = ThreadingHTTPServer((host, port), Handler)
    print(f"Arena Intel listening on http://{host}:{port}")
    httpd.serve_forever()


if __name__ == "__main__":
    main()
