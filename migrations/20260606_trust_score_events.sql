-- Trust score activity ledger (CRED-style report feed)
BEGIN;

CREATE TABLE IF NOT EXISTS trust_score_events (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid                 TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  event_type          TEXT NOT NULL,
  category            TEXT NOT NULL CHECK (category IN ('profile', 'behavior', 'penalty', 'system')),

  title               TEXT NOT NULL,
  body                TEXT,

  delta_profile       SMALLINT NOT NULL DEFAULT 0,
  delta_behavior      SMALLINT NOT NULL DEFAULT 0,
  delta_total         SMALLINT NOT NULL DEFAULT 0,

  profile_points_after   SMALLINT,
  behavior_points_after  SMALLINT,
  score_before           SMALLINT NOT NULL,
  score_after            SMALLINT NOT NULL,
  tier_after             trust_tier_type,

  metadata            JSONB NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_trust_events_uid_created
  ON trust_score_events(uid, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_trust_events_uid_category
  ON trust_score_events(uid, category, created_at DESC);

COMMIT;
