-- Query pack for interviews. Run after seed.py:
-- sqlite3 career/projects/arena-intel/arena.db < career/projects/arena-intel/queries.sql

.headers on
.mode column

-- 1. Global leaderboard from the view (uses grouped stats, not raw match spam)
SELECT username, country, best_score, win_rate, matches_played
FROM v_player_form
ORDER BY best_score DESC
LIMIT 10;

-- 2. Category difficulty across the whole population
SELECT c.title,
       COUNT(*) AS attempts,
       ROUND(100.0 * SUM(a.correct) / COUNT(*), 1) AS accuracy
FROM match_answers a
JOIN categories c ON c.id = a.category_id
GROUP BY c.id
ORDER BY accuracy ASC;

-- 3. Players whose last-5 average is below their career average (form dip)
WITH last5 AS (
  SELECT player_id, AVG(score) AS recent_avg
  FROM (
    SELECT player_id, score,
           ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY played_at DESC) AS rn
    FROM matches
  )
  WHERE rn <= 5
  GROUP BY player_id
)
SELECT p.username, ROUND(v.avg_score, 1) AS career_avg, ROUND(l.recent_avg, 1) AS last5_avg
FROM last5 l
JOIN v_player_form v ON v.player_id = l.player_id
JOIN players p ON p.id = l.player_id
WHERE l.recent_avg < v.avg_score
ORDER BY (v.avg_score - l.recent_avg) DESC;

-- 4. Explain-friendly: confirm the player+time index exists
EXPLAIN QUERY PLAN
SELECT score FROM matches WHERE player_id = 1 ORDER BY played_at DESC LIMIT 5;
