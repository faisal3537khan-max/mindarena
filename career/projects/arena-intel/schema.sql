PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS players (
  id INTEGER PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  country TEXT NOT NULL,
  university TEXT NOT NULL DEFAULT 'Independent',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS seasons (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  starts_on TEXT NOT NULL,
  ends_on TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS matches (
  id INTEGER PRIMARY KEY,
  player_id INTEGER NOT NULL REFERENCES players(id),
  season_id INTEGER NOT NULL REFERENCES seasons(id),
  mode TEXT NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0),
  won INTEGER NOT NULL CHECK (won IN (0, 1)),
  played_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS match_answers (
  id INTEGER PRIMARY KEY,
  match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  correct INTEGER NOT NULL CHECK (correct IN (0, 1)),
  latency_ms INTEGER NOT NULL CHECK (latency_ms >= 0)
);

CREATE INDEX IF NOT EXISTS idx_matches_player_time ON matches(player_id, played_at DESC);
CREATE INDEX IF NOT EXISTS idx_matches_score ON matches(score DESC);
CREATE INDEX IF NOT EXISTS idx_players_country ON players(country);
CREATE INDEX IF NOT EXISTS idx_answers_category ON match_answers(category_id);

CREATE VIEW IF NOT EXISTS v_player_form AS
SELECT
  p.id AS player_id,
  p.username,
  p.country,
  COUNT(m.id) AS matches_played,
  SUM(m.won) AS wins,
  ROUND(100.0 * SUM(m.won) / COUNT(m.id), 1) AS win_rate,
  MAX(m.score) AS best_score,
  AVG(m.score) AS avg_score
FROM players p
JOIN matches m ON m.player_id = p.id
GROUP BY p.id;

CREATE VIEW IF NOT EXISTS v_category_skill AS
SELECT
  p.id AS player_id,
  p.username,
  c.title AS category,
  COUNT(*) AS attempts,
  ROUND(100.0 * SUM(a.correct) / COUNT(*), 1) AS accuracy,
  ROUND(AVG(a.latency_ms), 0) AS avg_ms
FROM players p
JOIN matches m ON m.player_id = p.id
JOIN match_answers a ON a.match_id = m.id
JOIN categories c ON c.id = a.category_id
GROUP BY p.id, c.id;

CREATE VIEW IF NOT EXISTS v_season_standings AS
SELECT
  s.name AS season,
  p.username,
  p.country,
  SUM(m.score) AS season_points,
  COUNT(m.id) AS matches_played
FROM seasons s
JOIN matches m ON m.season_id = s.id
JOIN players p ON p.id = m.player_id
GROUP BY s.id, p.id
ORDER BY season_points DESC;
