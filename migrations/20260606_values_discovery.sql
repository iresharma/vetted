-- Values discovery + Daily 5 personalisation

CREATE TYPE weight_map_status_type AS ENUM ('pending', 'completed', 'skipped');
CREATE TYPE weight_map_source_type AS ENUM ('quiz', 'community_default', 'learned');

CREATE TYPE pass_reason_type AS ENUM (
  'different_timeline',
  'lifestyle_mismatch',
  'family_values',
  'location',
  'not_my_type',
  'other'
);

CREATE TABLE user_weight_maps (
  uid             TEXT PRIMARY KEY REFERENCES users(uid) ON DELETE CASCADE,
  status          weight_map_status_type NOT NULL DEFAULT 'pending',
  source          weight_map_source_type,
  weight_map      JSONB NOT NULL DEFAULT '{}',
  quiz_answers    JSONB NOT NULL DEFAULT '{}',
  learning_log    JSONB NOT NULL DEFAULT '[]',
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_weight_maps_status ON user_weight_maps(status);

CREATE TABLE community_weight_defaults (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  faith           faith_type,
  mother_tongue   TEXT,
  weight_map      JSONB NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE NULLS NOT DISTINCT (faith, mother_tongue)
);

ALTER TABLE interactions
  ADD COLUMN IF NOT EXISTS pass_reason pass_reason_type,
  ADD COLUMN IF NOT EXISTS pass_reason_field TEXT;

ALTER TABLE daily_queue
  ADD COLUMN IF NOT EXISTS match_reason_field TEXT,
  ADD COLUMN IF NOT EXISTS match_reason_label TEXT;

ALTER TABLE user_weight_maps ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_weight_defaults ENABLE ROW LEVEL SECURITY;

CREATE POLICY p_weight_maps_self ON user_weight_maps USING (uid = current_uid());
CREATE POLICY p_community_defaults_read ON community_weight_defaults FOR SELECT USING (TRUE);
