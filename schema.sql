-- ============================================================
--  THE VETTED CLUB — Clean PostgreSQL Schema
--  Version 3.1 | June 2026
--  Tables + Indexes + Enums + RLS only.
--  No triggers. No stored functions. No computed columns.
--  All logic lives in Cloud Functions (JS/Python).
--
--  FIRESTORE (not in this schema):
--    chat_threads/{threadId}   — match threads, last message preview, unread counts
--    chat_threads/{threadId}/messages/{messageId}
--    user_presence/{uid}       — online status, last_seen_at, device info
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";


-- ============================================================
--  ENUMS
-- ============================================================

CREATE TYPE gender_type AS ENUM (
  'man', 'woman', 'non_binary', 'prefer_not_to_say'
);
CREATE TYPE diet_type AS ENUM (
  'vegetarian', 'non_vegetarian', 'eggetarian',
  'vegan', 'jain', 'prefer_not_to_say'
);
CREATE TYPE drinking_type AS ENUM (
  'never', 'socially', 'regularly', 'prefer_not_to_say'
);
CREATE TYPE smoking_type AS ENUM (
  'never', 'socially', 'regularly', 'prefer_not_to_say'
);
CREATE TYPE family_type AS ENUM (
  'nuclear', 'joint', 'open_to_either', 'prefer_not_to_say'
);
CREATE TYPE faith_type AS ENUM (
  'hindu', 'muslim', 'sikh', 'christian', 'jain',
  'buddhist', 'agnostic', 'atheist', 'other', 'prefer_not_to_say'
);
CREATE TYPE work_mode_type AS ENUM (
  'remote', 'in_office', 'hybrid', 'prefer_not_to_say'
);
CREATE TYPE marriage_timeline_type AS ENUM (
  'within_6_months', 'within_1_year', '1_to_2_years', '2_to_3_years', 'exploring'
);
CREATE TYPE marital_status_type AS ENUM (
  'never_married', 'divorced', 'widowed', 'separated'
);
CREATE TYPE family_involvement_type AS ENUM (
  'parents_leading', 'i_decide_they_know', 'private_for_now'
);
CREATE TYPE kids_preference_type AS ENUM (
  'want_kids', 'open_to_kids', 'do_not_want',
  'have_kids', 'prefer_not_to_say'
);
CREATE TYPE trust_tier_type AS ENUM (
  'trusted', 'highly_trusted', 'elite'
);
CREATE TYPE subscription_status_type AS ENUM (
  'active', 'cancelled', 'expired', 'paused'
);
CREATE TYPE subscription_plan_type AS ENUM (
  'monthly', 'annual'
);
CREATE TYPE event_status_type AS ENUM (
  'draft', 'upcoming', 'live', 'completed', 'cancelled'
);
CREATE TYPE ticket_status_type AS ENUM (
  'confirmed', 'cancelled', 'attended', 'no_show', 'refunded'
);
CREATE TYPE interaction_type AS ENUM (
  'passed', 'interested', 'matched', 'unmatched', 'blocked'
);
CREATE TYPE report_reason_type AS ENUM (
  'fake_profile', 'inappropriate_behaviour',
  'harassment', 'spam', 'other'
);
CREATE TYPE account_status_type AS ENUM (
  'pending_verification', 'active', 'suspended', 'deleted'
);
CREATE TYPE identity_verification_status_type AS ENUM (
  'pending', 'completed', 'failed', 'expired'
);
CREATE TYPE identity_verification_provider_type AS ENUM (
  'setu_digilocker'
);
CREATE TYPE notification_type AS ENUM (
  'new_match', 'new_message', 'daily_queue_ready',
  'event_reminder', 'pre_event_match',
  'trust_tier_upgrade', 'subscription_expiring',
  'profile_incomplete', 'system'
);


-- ============================================================
--  1. USERS
--  uid = Firebase Auth UID — this is your primary key everywhere.
--  verified_name + verified_dob are written once by your Cloud
--  Function after DigiLocker callback. Never writable by client.
-- ============================================================

CREATE TABLE users (
  uid                       TEXT PRIMARY KEY,
  phone                     TEXT UNIQUE NOT NULL,
  email                     TEXT UNIQUE,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_active_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  account_status            account_status_type NOT NULL DEFAULT 'pending_verification',

  -- Set by Cloud Function after DigiLocker — never by client
  verified_name             TEXT,
  verified_dob              DATE,
  verified_age              SMALLINT,             -- written by CF, not computed
  is_identity_verified      BOOLEAN NOT NULL DEFAULT FALSE,
  identity_verified_at      TIMESTAMPTZ,

  -- Set by Cloud Function after Razorpay callback
  has_paid_entry_pass       BOOLEAN NOT NULL DEFAULT FALSE,
  entry_pass_paid_at        TIMESTAMPTZ,
  razorpay_entry_order_id   TEXT,
  razorpay_entry_payment_id TEXT
);

CREATE INDEX idx_users_status      ON users(account_status);
CREATE INDEX idx_users_last_active ON users(last_active_at DESC);


-- ============================================================
--  2. IDENTITY VERIFICATIONS (Setu + DigiLocker)
--  One row per verification attempt. Raw Aadhaar is NEVER stored.
--  Your Cloud Function:
--    1. Creates a Setu DigiLocker session → status = pending
--    2. On callback, HMAC-SHA256(normalized_aadhaar, server_pepper)
--       → aadhaar_hash (for duplicate-account detection only)
--    3. Writes verified_name / verified_dob to this row AND users table
--  Client reads verification status from users.is_identity_verified.
-- ============================================================

CREATE TABLE identity_verifications (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid                     TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,

  provider                identity_verification_provider_type NOT NULL DEFAULT 'setu_digilocker',
  status                  identity_verification_status_type NOT NULL DEFAULT 'pending',

  -- Setu session identifiers — written at initiation / callback
  setu_request_id         TEXT UNIQUE,
  setu_verification_id    TEXT,

  -- HMAC-SHA256 of normalized Aadhaar + server-side pepper.
  -- Populated only on status = completed. Used to block re-registration
  -- with the same Aadhaar on a different account. Never exposed to client.
  aadhaar_hash            BYTEA,
  aadhaar_hash_version    SMALLINT NOT NULL DEFAULT 1,

  -- Snapshot from Setu callback (also copied to users on success)
  verified_name           TEXT,
  verified_dob            DATE,

  initiated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at            TIMESTAMPTZ,
  expires_at              TIMESTAMPTZ,
  failure_reason          TEXT,

  -- Non-PII Setu metadata for debugging (request IDs, doc type, etc.)
  setu_callback_metadata  JSONB,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_idv_uid            ON identity_verifications(uid, created_at DESC);
CREATE INDEX idx_idv_setu_request   ON identity_verifications(setu_request_id)
  WHERE setu_request_id IS NOT NULL;
CREATE INDEX idx_idv_pending        ON identity_verifications(uid, status)
  WHERE status = 'pending';

-- One completed verification per Aadhaar across the entire platform
CREATE UNIQUE INDEX idx_idv_aadhaar_hash
  ON identity_verifications(aadhaar_hash)
  WHERE status = 'completed' AND aadhaar_hash IS NOT NULL;


-- ============================================================
--  3. PROFILES
--  Everything the user fills in during onboarding + settings.
--  completeness_pct deprecated — trust score lives in trust_scores.score (0–200).
--  is_live written by Cloud Function when all 21 required fields are filled.
-- ============================================================

CREATE TABLE profiles (
  uid                     TEXT PRIMARY KEY REFERENCES users(uid) ON DELETE CASCADE,
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  display_name            TEXT,
  gender                  gender_type,
  city                    TEXT,
  home_state              TEXT,
  height_cm               SMALLINT,
  body_type               TEXT,
  marital_status          marital_status_type,
  has_children            TEXT,

  profession              TEXT,
  field_of_work           TEXT,
  employment_type         TEXT,
  company                 TEXT,
  education_level         TEXT,
  college                 TEXT,
  income_bracket          TEXT,
  work_mode               work_mode_type,

  faith                   faith_type,
  religiosity             TEXT,
  community               TEXT,           -- freeform, never a dropdown
  sub_caste               TEXT,
  mother_tongue           TEXT,
  languages_spoken        TEXT[],
  manglik_status          TEXT,
  rashi                   TEXT,
  nakshatra               TEXT,
  gotra                   TEXT,
  birth_time              TIME,
  birth_place             TEXT,
  living_arrangement_post_marriage TEXT,
  father_occupation       TEXT,
  mother_occupation       TEXT,
  siblings                TEXT,
  family_location         TEXT,
  grew_up_abroad          BOOLEAN DEFAULT FALSE,
  family_structure        family_type,
  horoscope_matters       BOOLEAN,

  diet                    diet_type,
  drinking                drinking_type,
  smoking                 smoking_type,

  marriage_timeline       marriage_timeline_type,
  family_involvement      family_involvement_type,
  kids_preference         kids_preference_type,
  willing_to_relocate     BOOLEAN,
  open_to_inter_faith     BOOLEAN DEFAULT TRUE,
  open_to_inter_community BOOLEAN DEFAULT TRUE,

  prompt_1_q              TEXT,
  prompt_1_a              TEXT,
  prompt_2_q              TEXT,
  prompt_2_a              TEXT,
  prompt_3_q              TEXT,
  prompt_3_a              TEXT,

  photo_urls              TEXT[],         -- ordered array of storage URLs
  voice_note_url          TEXT,
  video_intro_url         TEXT,

  interests               TEXT[],
  profile_extras          JSONB NOT NULL DEFAULT '{}',

  -- Written by Cloud Function on every profile update
  completeness_pct        SMALLINT NOT NULL DEFAULT 0,
  is_live                 BOOLEAN NOT NULL DEFAULT FALSE,
  is_paused               BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_profiles_city       ON profiles(city);
CREATE INDEX idx_profiles_faith      ON profiles(faith);
CREATE INDEX idx_profiles_diet       ON profiles(diet);
CREATE INDEX idx_profiles_live       ON profiles(is_live, is_paused);
CREATE INDEX idx_profiles_timeline   ON profiles(marriage_timeline);
CREATE INDEX idx_profiles_community  ON profiles USING GIN (community gin_trgm_ops);
CREATE INDEX idx_profiles_interests  ON profiles USING GIN (interests);


-- ============================================================
--  4. PREFERENCES & DEALBREAKERS
--  NULL on any db_ field = no preference / any is fine.
--  rank_ fields: 1 = highest priority, 7 = lowest.
--  Your Cloud Function converts rank to weight: weight = 8 - rank
-- ============================================================

CREATE TABLE preferences (
  uid                         TEXT PRIMARY KEY REFERENCES users(uid) ON DELETE CASCADE,
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  pref_age_min                SMALLINT NOT NULL DEFAULT 21,
  pref_age_max                SMALLINT NOT NULL DEFAULT 35,
  pref_height_min_cm          SMALLINT,
  pref_height_max_cm          SMALLINT,

  -- Hard filters — NULL means no filter applied
  db_city                     TEXT[],
  db_gender                   gender_type[],
  db_faith                    faith_type[],
  db_diet                     diet_type[],
  db_drinking                 drinking_type[],
  db_smoking                  smoking_type[],
  db_family_structure         family_type[],
  db_marriage_timeline        marriage_timeline_type[],

  -- Weighted priority ranks (used by matching CF to score candidates)
  rank_education              SMALLINT CHECK (rank_education BETWEEN 1 AND 7),
  rank_career                 SMALLINT CHECK (rank_career BETWEEN 1 AND 7),
  rank_lifestyle              SMALLINT CHECK (rank_lifestyle BETWEEN 1 AND 7),
  rank_timeline               SMALLINT CHECK (rank_timeline BETWEEN 1 AND 7),
  rank_family_values          SMALLINT CHECK (rank_family_values BETWEEN 1 AND 7),
  rank_ambition               SMALLINT CHECK (rank_ambition BETWEEN 1 AND 7),
  rank_location_flexibility   SMALLINT CHECK (rank_location_flexibility BETWEEN 1 AND 7)
);


-- ============================================================
--  5. SUBSCRIPTIONS
--  Your Cloud Function writes a new row on each Razorpay
--  subscription webhook. Check active status by querying
--  status = 'active' AND current_period_end > NOW()
-- ============================================================

CREATE TABLE subscriptions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid                     TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  plan                    subscription_plan_type NOT NULL,
  status                  subscription_status_type NOT NULL DEFAULT 'active',
  started_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  current_period_start    TIMESTAMPTZ NOT NULL,
  current_period_end      TIMESTAMPTZ NOT NULL,
  cancelled_at            TIMESTAMPTZ,
  cancel_reason           TEXT,
  razorpay_sub_id         TEXT UNIQUE,
  razorpay_plan_id        TEXT,
  amount_paise            INTEGER NOT NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subs_uid        ON subscriptions(uid);
CREATE INDEX idx_subs_status     ON subscriptions(status);
CREATE INDEX idx_subs_period_end ON subscriptions(current_period_end);


-- ============================================================
--  6. TRUST SCORES
--  One row per user. All fields written by your Cloud Function.
--  Your CF calls refreshTrustScore(uid) after:
--    - event attendance / no-show
--    - new interaction (match/pass)
--    - valid report filed against user
--    - profile field save
--  score = profile_points (max 150) + behavior_points (max 50) − reports × 25
-- ============================================================

CREATE TABLE trust_scores (
  uid                         TEXT PRIMARY KEY REFERENCES users(uid) ON DELETE CASCADE,
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  events_attended             SMALLINT NOT NULL DEFAULT 0,
  events_booked               SMALLINT NOT NULL DEFAULT 0,
  response_rate_pct           SMALLINT NOT NULL DEFAULT 100,
  positive_feedback_count     SMALLINT NOT NULL DEFAULT 0,
  negative_feedback_count     SMALLINT NOT NULL DEFAULT 0,
  reports_received            SMALLINT NOT NULL DEFAULT 0,
  profile_points              SMALLINT NOT NULL DEFAULT 0,
  behavior_points             SMALLINT NOT NULL DEFAULT 0,
  profile_completeness_pct    SMALLINT NOT NULL DEFAULT 0,  -- deprecated
  account_age_days            INTEGER  NOT NULL DEFAULT 0,

  -- Written by CF after recompute (0–200)
  score                       SMALLINT NOT NULL DEFAULT 0,
  tier                        trust_tier_type NOT NULL DEFAULT 'trusted',

  is_banned                   BOOLEAN NOT NULL DEFAULT FALSE,
  banned_at                   TIMESTAMPTZ,
  ban_reason                  TEXT,
  ban_expires_at              TIMESTAMPTZ
);

CREATE INDEX idx_trust_score  ON trust_scores(score DESC);
CREATE INDEX idx_trust_tier   ON trust_scores(tier);
CREATE INDEX idx_trust_banned ON trust_scores(is_banned) WHERE is_banned = TRUE;


-- ============================================================
--  6b. TRUST SCORE EVENTS (activity ledger / CRED-style feed)
-- ============================================================

CREATE TABLE trust_score_events (
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

CREATE INDEX idx_trust_events_uid_created
  ON trust_score_events(uid, created_at DESC);


-- ============================================================
--  7. INTERACTIONS
--  Every pass / interest / match / block between two users.
--  actor_uid acted on target_uid.
--  Your CF checks for mutual interest and sets is_mutual = true.
-- ============================================================

CREATE TABLE interactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_uid       TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  target_uid      TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  type            interaction_type NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_mutual       BOOLEAN NOT NULL DEFAULT FALSE,
  matched_at      TIMESTAMPTZ,
  source          TEXT,   -- 'daily_queue' | 'pre_event' | 'direct'

  UNIQUE (actor_uid, target_uid)
);

CREATE INDEX idx_inter_actor   ON interactions(actor_uid, type);
CREATE INDEX idx_inter_target  ON interactions(target_uid, type);
CREATE INDEX idx_inter_mutual  ON interactions(is_mutual, matched_at DESC)
  WHERE is_mutual = TRUE;
CREATE INDEX idx_inter_seen    ON interactions(actor_uid)
  WHERE type IN ('passed', 'interested', 'matched', 'blocked');


-- ============================================================
--  8. DAILY QUEUE
--  Written by your Cloud Function every morning at 6am IST.
--  App reads: SELECT * FROM daily_queue
--             WHERE uid = ? AND queue_date = today
--             ORDER BY position ASC
-- ============================================================

CREATE TABLE daily_queue (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid                   TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  profile_uid           TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  queue_date            DATE NOT NULL DEFAULT CURRENT_DATE,
  position              SMALLINT NOT NULL CHECK (position BETWEEN 1 AND 5),
  compatibility_score   SMALLINT NOT NULL,
  score_breakdown       JSONB,           -- {"education":18,"lifestyle":14,...}
  was_shown             BOOLEAN NOT NULL DEFAULT FALSE,
  shown_at              TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (uid, queue_date, position),
  UNIQUE (uid, profile_uid, queue_date)
);

CREATE INDEX idx_queue_uid_date ON daily_queue(uid, queue_date);


-- ============================================================
--  9. EVENTS
-- ============================================================

CREATE TABLE events (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title                   TEXT NOT NULL,
  description             TEXT,
  city                    TEXT NOT NULL,
  neighbourhood           TEXT,
  venue_name              TEXT,
  venue_address           TEXT,
  venue_lat               NUMERIC(9,6),
  venue_lng               NUMERIC(9,6),
  event_date              TIMESTAMPTZ NOT NULL,
  doors_open_at           TIMESTAMPTZ,
  ends_at                 TIMESTAMPTZ,
  status                  event_status_type NOT NULL DEFAULT 'upcoming',
  cover_image_url         TEXT,
  ticket_price_paise      INTEGER NOT NULL,
  capacity                SMALLINT NOT NULL DEFAULT 30,
  tickets_sold            SMALLINT NOT NULL DEFAULT 0,   -- updated by CF
  min_trust_tier          trust_tier_type,
  tags                    TEXT[],
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_events_city_date ON events(city, event_date);
CREATE INDEX idx_events_status    ON events(status);


-- ============================================================
--  10. EVENT TICKETS
-- ============================================================

CREATE TABLE event_tickets (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id                  UUID NOT NULL REFERENCES events(id) ON DELETE RESTRICT,
  uid                       TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  status                    ticket_status_type NOT NULL DEFAULT 'confirmed',
  ticket_price_paid_paise   INTEGER NOT NULL,
  razorpay_order_id         TEXT UNIQUE,
  razorpay_payment_id       TEXT,
  check_in_code             TEXT UNIQUE DEFAULT encode(gen_random_bytes(6), 'hex'),
  booked_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  attended_at               TIMESTAMPTZ,
  cancelled_at              TIMESTAMPTZ,
  refunded_at               TIMESTAMPTZ,

  UNIQUE (event_id, uid)
);

CREATE INDEX idx_tickets_uid   ON event_tickets(uid);
CREATE INDEX idx_tickets_event ON event_tickets(event_id, status);
CREATE INDEX idx_tickets_code  ON event_tickets(check_in_code);


-- ============================================================
--  11. PRE-EVENT MATCHES
--  Written by CF 48h before each event.
--  Query: SELECT * FROM pre_event_matches
--         WHERE uid = ? AND event_id = ?
--         ORDER BY position ASC
-- ============================================================

CREATE TABLE pre_event_matches (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id              UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  uid                   TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  matched_uid           TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  position              SMALLINT NOT NULL CHECK (position BETWEEN 1 AND 3),
  compatibility_score   SMALLINT NOT NULL,
  was_shown             BOOLEAN NOT NULL DEFAULT FALSE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (event_id, uid, position),
  UNIQUE (event_id, uid, matched_uid)
);

CREATE INDEX idx_pre_event ON pre_event_matches(uid, event_id);


-- ============================================================
--  12. PUSH TOKENS
--  One user can have multiple devices.
-- ============================================================

CREATE TABLE push_tokens (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid          TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  token        TEXT UNIQUE NOT NULL,
  platform     TEXT NOT NULL,   -- 'ios' | 'android'
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_used_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_push_uid ON push_tokens(uid) WHERE is_active = TRUE;


-- ============================================================
--  13. NOTIFICATIONS
-- ============================================================

CREATE TABLE notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid             TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  type            notification_type NOT NULL,
  title           TEXT NOT NULL,
  body            TEXT,
  data            JSONB,          -- deep link payload, related IDs
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  read_at         TIMESTAMPTZ,
  push_sent_at    TIMESTAMPTZ,
  push_delivered  BOOLEAN,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifs_uid    ON notifications(uid, created_at DESC);
CREATE INDEX idx_notifs_unread ON notifications(uid, is_read) WHERE is_read = FALSE;


-- ============================================================
--  14. REPORTS
-- ============================================================

CREATE TABLE reports (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_uid   TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  reported_uid   TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  reason         report_reason_type NOT NULL,
  detail         TEXT,
  evidence_urls  TEXT[],
  is_reviewed    BOOLEAN NOT NULL DEFAULT FALSE,
  is_valid       BOOLEAN,
  reviewer_notes TEXT,
  reviewed_at    TIMESTAMPTZ,
  action_taken   TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (reporter_uid, reported_uid)
);

CREATE INDEX idx_reports_reported   ON reports(reported_uid, is_reviewed);
CREATE INDEX idx_reports_unreviewed ON reports(is_reviewed, created_at)
  WHERE is_reviewed = FALSE;


-- ============================================================
--  15. BLOCKED USERS
-- ============================================================

CREATE TABLE blocked_users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_uid  TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  blocked_uid  TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE (blocker_uid, blocked_uid)
);

CREATE INDEX idx_blocks_blocker ON blocked_users(blocker_uid);
CREATE INDEX idx_blocks_blocked ON blocked_users(blocked_uid);


-- ============================================================
--  16. ADMIN AUDIT LOG
--  Append-only. Never update or delete rows here.
-- ============================================================

CREATE TABLE admin_audit_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_uid   TEXT NOT NULL,
  target_uid  TEXT REFERENCES users(uid) ON DELETE SET NULL,
  action      TEXT NOT NULL,
  detail      JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_target ON admin_audit_log(target_uid, created_at DESC);
CREATE INDEX idx_audit_admin  ON admin_audit_log(admin_uid, created_at DESC);


-- ============================================================
--  ROW LEVEL SECURITY
--  All logic enforced at DB level.
--  Your Cloud Functions run as service role (bypasses RLS).
--  Client SDK runs as authenticated user (RLS applies).
-- ============================================================

ALTER TABLE users                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE identity_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE preferences            ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions          ENABLE ROW LEVEL SECURITY;
ALTER TABLE trust_scores           ENABLE ROW LEVEL SECURITY;
ALTER TABLE interactions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_queue            ENABLE ROW LEVEL SECURITY;
ALTER TABLE events                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_tickets          ENABLE ROW LEVEL SECURITY;
ALTER TABLE pre_event_matches      ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens            ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications     ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports           ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users     ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_audit_log   ENABLE ROW LEVEL SECURITY;

-- Helper: reads Firebase Auth UID from JWT claim
CREATE OR REPLACE FUNCTION current_uid() RETURNS TEXT AS $$
  SELECT NULLIF(current_setting('app.current_uid', TRUE), '')
$$ LANGUAGE SQL STABLE;

-- users: own row only
CREATE POLICY p_users_self
  ON users USING (uid = current_uid());

-- identity verifications: service role only (contains aadhaar_hash)
CREATE POLICY p_idv_deny
  ON identity_verifications USING (FALSE);

-- profiles: own row full access
CREATE POLICY p_profiles_own
  ON profiles FOR ALL
  USING (uid = current_uid());

-- profiles: read others only if they're live + reader has active sub + not blocked
CREATE POLICY p_profiles_others
  ON profiles FOR SELECT
  USING (
    uid != current_uid()
    AND is_live = TRUE
    AND is_paused = FALSE
    AND EXISTS (
      SELECT 1 FROM subscriptions
      WHERE uid = current_uid()
        AND status = 'active'
        AND current_period_end > NOW()
    )
    AND uid NOT IN (
      SELECT blocked_uid FROM blocked_users WHERE blocker_uid = current_uid()
      UNION ALL
      SELECT blocker_uid FROM blocked_users WHERE blocked_uid = current_uid()
    )
  );

-- simple own-row policies
CREATE POLICY p_prefs_self      ON preferences       USING (uid = current_uid());
CREATE POLICY p_subs_self       ON subscriptions     USING (uid = current_uid());
CREATE POLICY p_trust_self      ON trust_scores      USING (uid = current_uid());
CREATE POLICY p_queue_self      ON daily_queue       USING (uid = current_uid());
CREATE POLICY p_tickets_self    ON event_tickets     USING (uid = current_uid());
CREATE POLICY p_pre_event_self  ON pre_event_matches USING (uid = current_uid());
CREATE POLICY p_tokens_self     ON push_tokens       USING (uid = current_uid());
CREATE POLICY p_notifs_self     ON notifications     USING (uid = current_uid());
CREATE POLICY p_blocks_self     ON blocked_users     USING (blocker_uid = current_uid());
CREATE POLICY p_reports_self    ON reports           USING (reporter_uid = current_uid());
CREATE POLICY p_audit_deny      ON admin_audit_log   USING (FALSE); -- service role only

-- interactions: both participants can read
CREATE POLICY p_inter_participant
  ON interactions
  USING (actor_uid = current_uid() OR target_uid = current_uid());

-- events: public read, no write from client
CREATE POLICY p_events_public ON events FOR SELECT USING (TRUE);



-- npg_LR68CWfANVQa