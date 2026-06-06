-- Trust Score migration (June 2026)
-- Profile Trust max 150, Behavior Trust max 50, total score max 200.

BEGIN;

ALTER TABLE trust_scores
  ADD COLUMN IF NOT EXISTS profile_points SMALLINT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS behavior_points SMALLINT NOT NULL DEFAULT 0;

-- Backfill trust_scores rows for users missing one.
INSERT INTO trust_scores (uid)
SELECT u.uid FROM users u
LEFT JOIN trust_scores t ON t.uid = u.uid
WHERE t.uid IS NULL;

COMMIT;
