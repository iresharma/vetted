const path = require("node:path");
const { getPool } = require("./pg-pool");
const { getFieldValue, dbKeyForField, EXTRAS_FIELDS } = require(
  path.join(__dirname, "../../functions/src/matching/field_registry")
);
const { passesHardFilter } = require(
  path.join(__dirname, "../../functions/src/matching/field_scorers")
);
const { scoreCandidate } = require(
  path.join(__dirname, "../../functions/src/matching/score_candidate")
);
const { computeTrustScore, computeTrustTier } = require(path.join(__dirname, "../../functions/src/trust"));
const { buildGlobalDefaultWeightMap } = require(
  path.join(__dirname, "../../functions/src/matching/field_registry")
);
const {
  scenarioIdForIndex,
  describeScenario,
  trustScoreForScenario,
  applyProdLikeMatchScenario,
  SCENARIOS,
} = require("./prod-like-scenarios");
const { loadCommunityDefault } = require(path.join(__dirname, "../../functions/src/values"));

const MANIFEST_PATH = path.join(__dirname, "../.test-users-manifest.json");

const FEMALE_NAMES = [
  "Priya",
  "Ananya",
  "Kavya",
  "Meera",
  "Ishita",
  "Sneha",
  "Divya",
  "Nandini",
  "Riya",
  "Aisha",
];

const MALE_NAMES = [
  "Arjun",
  "Rohan",
  "Vikram",
  "Karan",
  "Aditya",
  "Rahul",
  "Dev",
  "Nikhil",
  "Aman",
  "Kabir",
];

const CITIES = ["Bengaluru", "Mumbai", "Delhi", "Hyderabad", "Pune", "Chennai"];
const FAITHS = ["hindu", "muslim", "sikh", "christian", "jain"];
const TONGUES = ["Hindi", "Tamil", "Telugu", "Marathi", "Bengali", "Kannada"];

function normalizePhone(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.length === 10) return `+91${digits}`;
  if (digits.length === 12 && digits.startsWith("91")) return `+${digits}`;
  if (String(raw || "").startsWith("+")) return String(raw).trim();
  throw new Error(`Invalid phone number: ${raw}`);
}

function inferOppositeGender(gender) {
  const g = String(gender || "").toLowerCase();
  if (g === "man") return "woman";
  if (g === "woman") return "man";
  return "woman";
}

function inferPartnerGenders(viewer) {
  if (viewer.db_gender && viewer.db_gender.length > 0) {
    return viewer.db_gender;
  }
  return [inferOppositeGender(viewer.gender)];
}

function partnerGenderForIndex(viewer, index) {
  const genders = inferPartnerGenders(viewer);
  return genders[(index - 1) % genders.length];
}

function partnerAgeForIndex(viewer, index, total) {
  const min = viewer.pref_age_min ?? 21;
  const max = viewer.pref_age_max ?? 35;
  if (total <= 1 || min >= max) return min;
  const step = (max - min) / (total - 1);
  return Math.round(min + step * (index - 1));
}

function testPhoneE164(index) {
  const local = String(9000000000 + index);
  return `+91${local}`;
}

function testPhoneDisplay(index) {
  return String(9000000000 + index);
}

function photoUrlsFor(index) {
  return [1, 2, 3].map(
    (slot) => `https://picsum.photos/seed/vetted-test-${index}-${slot}/400/600`
  );
}

function dobForAge(age) {
  const year = new Date().getFullYear() - age;
  return `${year}-06-15`;
}

function setProfileField(profile, fieldId, value) {
  if (value == null) return;
  if (EXTRAS_FIELDS.has(fieldId)) {
    profile.profile_extras[fieldId] = value;
    return;
  }
  profile[dbKeyForField(fieldId)] = value;
}

function listHardFilterFields(weightMapRow) {
  const fields = weightMapRow?.weight_map?.fields || {};
  return Object.entries(fields)
    .filter(([, entry]) => entry.mode === "hard")
    .map(([fieldId]) => fieldId);
}

function resolveHardFilterValue(fieldId, viewerContext, index) {
  const { viewer, weightMapRow } = viewerContext;
  const quizAnswers = weightMapRow?.quiz_answers || {};
  const acceptable = quizAnswers.dealbreakers?.acceptable?.[fieldId];

  if (acceptable && acceptable.length > 0) {
    return acceptable[(index - 1) % acceptable.length];
  }

  const viewerValue = getFieldValue(viewer, fieldId);
  if (viewerValue != null) return viewerValue;

  return null;
}

function applyHardFilterCompatibility(profile, viewerContext, index) {
  const hardFields = listHardFilterFields(viewerContext.weightMapRow);
  for (const fieldId of hardFields) {
    const value = resolveHardFilterValue(fieldId, viewerContext, index);
    setProfileField(profile, fieldId, value);
  }
}

function buildCandidateProfileRow(profile) {
  return {
    ...profile,
    profile_extras: profile.profile_extras || {},
  };
}

function assertPartnerCompatible(viewerContext, profile, index, options = {}) {
  const { viewer, weightMapRow } = viewerContext;
  const candidateProfile = buildCandidateProfileRow(profile);
  const weightMap = weightMapRow?.weight_map || { fields: {} };
  const quizAnswers = weightMapRow?.quiz_answers || {};
  const candidateTrustScore =
    options.candidateTrustScore ?? trustScoreForScenario(options.scenarioId ?? 1);

  for (const fieldId of listHardFilterFields(weightMapRow)) {
    if (!passesHardFilter(fieldId, viewer, candidateProfile, quizAnswers)) {
      const expected = resolveHardFilterValue(fieldId, viewerContext, index);
      const actual = getFieldValue(candidateProfile, fieldId);
      throw new Error(
        `Partner #${index} fails hard filter "${fieldId}" (expected compatible value, got ${JSON.stringify(actual)}, acceptable=${JSON.stringify(quizAnswers.dealbreakers?.acceptable?.[fieldId])})`
      );
    }
  }

  const scored = scoreCandidate({
    viewerProfile: viewer,
    candidateProfile,
    weightMap,
    quizAnswers,
    candidateTrustScore,
    priorShowCount: options.priorShowCount ?? 0,
  });

  if (scored.excluded) {
    throw new Error(`Partner #${index} was excluded by scoring despite hard-filter checks.`);
  }

  return scored;
}

function summarizePartnerPlan(viewerContext, count) {
  const { viewer, weightMapRow } = viewerContext;
  const hardFields = listHardFilterFields(weightMapRow);
  const genders = inferPartnerGenders(viewer);
  const ages = Array.from({ length: count }, (_, i) =>
    partnerAgeForIndex(viewer, i + 1, count)
  );

  return {
    viewerUid: viewer.uid,
    viewerName: viewer.display_name,
    viewerGender: viewer.gender,
    partnerGenders: genders,
    ageRange: {
      min: viewer.pref_age_min ?? 21,
      max: viewer.pref_age_max ?? 35,
      sampleAges: ages,
    },
    hardFilters: hardFields.map((fieldId) => ({
      fieldId,
      acceptable: weightMapRow?.quiz_answers?.dealbreakers?.acceptable?.[fieldId] || null,
      viewerValue: getFieldValue(viewer, fieldId),
    })),
    prodLikeScenarios: SCENARIOS.map(({ id, slug, label }) => ({ id, slug, label })),
  };
}

function buildProfilePayload({ index, gender, viewerContext, totalCount }) {
  const { viewer } = viewerContext;
  const names = gender === "woman" ? FEMALE_NAMES : MALE_NAMES;
  const name = names[(index - 1) % names.length];
  const city = viewer.city || CITIES[(index - 1) % CITIES.length];
  const faith = viewer.faith || FAITHS[(index - 1) % FAITHS.length];
  const tongue = viewer.mother_tongue || TONGUES[(index - 1) % TONGUES.length];
  const age = partnerAgeForIndex(viewer, index, totalCount);
  const displayName = `[TEST] ${name} ${index}`;

  const profile = {
    display_name: displayName,
    gender,
    city,
    home_state: viewer.home_state || "Karnataka",
    marital_status: "never_married",
    prompt_1_q: "A perfect Sunday looks like…",
    prompt_1_a: "Brunch, a long walk, and catching up with friends.",
    prompt_2_q: "I'm looking for someone who…",
    prompt_2_a: "Is kind, curious, and ready to build something meaningful.",
    prompt_3_q: "My friends would describe me as…",
    prompt_3_a: "Warm, dependable, and always up for good food.",
    photo_urls: photoUrlsFor(index),
    education_level: viewer.education_level || "Master's",
    field_of_work: viewer.field_of_work || "Software & technology",
    profession: viewer.profession || "Product Manager",
    faith,
    mother_tongue: tongue,
    family_structure: viewer.family_structure || "nuclear",
    family_involvement: viewer.family_involvement || "i_decide_they_know",
    diet: viewer.diet || "vegetarian",
    drinking: viewer.drinking || "socially",
    smoking: viewer.smoking || "never",
    marriage_timeline: viewer.marriage_timeline || "1_to_2_years",
    kids_preference: viewer.kids_preference || "want_kids",
    willing_to_relocate: viewer.willing_to_relocate ?? true,
    work_mode: viewer.work_mode || "hybrid",
    open_to_inter_faith: viewer.open_to_inter_faith ?? true,
    interests: ["Travel", "Food", "Fitness"],
    profile_extras: {
      is_test_user: true,
      seeded_for_viewer_uid: viewer.uid,
      weekend_vibe: viewer.profile_extras?.weekend_vibe || [
        "Foodie — trying new places",
        "Outdoors — hikes and runs",
      ],
      partner_search_approach:
        viewer.profile_extras?.partner_search_approach ||
        "Date first — get to know each other before deciding",
    },
  };

  applyHardFilterCompatibility(profile, viewerContext, index);

  const scenarioId = scenarioIdForIndex(index);
  applyProdLikeMatchScenario(profile, viewerContext, scenarioId);
  const scored = assertPartnerCompatible(viewerContext, profile, index, { scenarioId });
  const scenario = describeScenario(scenarioId);

  return {
    displayName,
    verifiedName: name,
    verifiedAge: age,
    verifiedDob: dobForAge(age),
    gender,
    city,
    faith,
    motherTongue: tongue,
    profile,
    preferences: {
      pref_age_min: Math.max(21, (viewer.verified_age || 28) - 5),
      pref_age_max: Math.min(35, (viewer.verified_age || 28) + 5),
      db_gender: viewer.gender ? [viewer.gender] : ["man", "woman"],
    },
    scenarioId,
    scenarioSlug: scenario.slug,
    scenarioLabel: scenario.label,
    targetTrustScore: trustScoreForScenario(scenarioId),
    previewCompatibilityScore: scored.compatibilityScore,
  };
}

async function loadViewerContext({ viewerUid, viewerPhone }) {
  const pool = getPool();
  const baseSelect = `
    SELECT u.uid, u.phone, u.account_status, u.verified_age,
           p.*,
           pref.pref_age_min, pref.pref_age_max, pref.db_gender,
           wm.status AS weight_map_status,
           wm.weight_map, wm.quiz_answers
    FROM users u
    JOIN profiles p ON p.uid = u.uid
    LEFT JOIN preferences pref ON pref.uid = u.uid
    LEFT JOIN user_weight_maps wm ON wm.uid = u.uid
  `;

  let rows;
  if (viewerUid) {
    ({ rows } = await pool.query(`${baseSelect} WHERE u.uid = $1`, [viewerUid]));
    if (rows.length === 0) throw new Error(`Viewer not found for uid ${viewerUid}`);
  } else if (viewerPhone) {
    const phone = normalizePhone(viewerPhone);
    ({ rows } = await pool.query(`${baseSelect} WHERE u.phone = $1`, [phone]));
    if (rows.length === 0) throw new Error(`Viewer not found for phone ${phone}`);
  } else {
    throw new Error("Provide --viewer-uid or --viewer-phone.");
  }

  const viewer = rows[0];
  if (!viewer.gender) {
    throw new Error(`Viewer ${viewer.uid} has no gender set on profile. Complete profile first.`);
  }
  if (viewer.verified_age == null) {
    throw new Error(`Viewer ${viewer.uid} has no verified_age. Complete identity verification first.`);
  }

  return {
    viewer,
    weightMapRow: {
      weight_map: viewer.weight_map,
      quiz_answers: viewer.quiz_answers || {},
      status: viewer.weight_map_status,
    },
  };
}

/** @deprecated use loadViewerContext */
async function loadViewer(args) {
  const ctx = await loadViewerContext(args);
  return ctx.viewer;
}

async function resolveWeightMap(profile) {
  try {
    const community = await loadCommunityDefault(profile.faith, profile.mother_tongue);
    if (community && typeof community === "object") return community;
  } catch {
    // Fall back to global defaults when community table is empty.
  }
  return buildGlobalDefaultWeightMap();
}

async function upsertTrustScore(client, uid, profileRow, options = {}) {
  const { trustScoreOverride } = options;

  await client.query(
    `INSERT INTO trust_scores(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`,
    [uid]
  );

  const computed = computeTrustScore({
    profileRow,
    trustRow: {},
    reportsCount: 0,
    mutualMatchCount: 0,
  });

  const trustScore =
    trustScoreOverride != null ? trustScoreOverride : computed.trustScore;
  const trustTier = computeTrustTier(trustScore);

  await client.query(
    `UPDATE profiles SET is_live = $2, updated_at = NOW() WHERE uid = $1`,
    [uid, computed.isLive]
  );

  await client.query(
    `UPDATE trust_scores
     SET score = $2, tier = $3, profile_points = $4, behavior_points = $5,
         reports_received = 0, updated_at = NOW()
     WHERE uid = $1`,
    [
      uid,
      trustScore,
      trustTier,
      computed.profilePoints,
      computed.behaviorPoints,
    ]
  );

  if (!computed.isLive) {
    throw new Error(`Seeded profile for ${uid} is not live after trust computation.`);
  }

  return { ...computed, trustScore, trustTier };
}

async function insertPostgresUser(client, { uid, phone, payload, weightMap }) {
  const { profile, preferences, verifiedName, verifiedAge, verifiedDob } = payload;

  await client.query(
    `INSERT INTO users(
       uid, phone, account_status, verified_name, verified_dob, verified_age,
       is_identity_verified, identity_verified_at,
       has_paid_entry_pass, entry_pass_paid_at, last_active_at
     ) VALUES (
       $1, $2, 'active', $3, $4::date, $5,
       TRUE, NOW(),
       TRUE, NOW(), NOW()
     )
     ON CONFLICT(uid) DO UPDATE SET
       phone = EXCLUDED.phone,
       account_status = 'active',
       verified_name = EXCLUDED.verified_name,
       verified_dob = EXCLUDED.verified_dob,
       verified_age = EXCLUDED.verified_age,
       is_identity_verified = TRUE,
       identity_verified_at = NOW(),
       has_paid_entry_pass = TRUE,
       entry_pass_paid_at = NOW(),
       last_active_at = NOW()`,
    [uid, phone, verifiedName, verifiedDob, verifiedAge]
  );

  await client.query(
    `INSERT INTO profiles(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`,
    [uid]
  );

  await client.query(
    `UPDATE profiles SET
       display_name = $2,
       gender = $3::gender_type,
       city = $4,
       home_state = $5,
       marital_status = $6::marital_status_type,
       prompt_1_q = $7,
       prompt_1_a = $8,
       prompt_2_q = $9,
       prompt_2_a = $10,
       prompt_3_q = $11,
       prompt_3_a = $12,
       photo_urls = $13,
       education_level = $14,
       field_of_work = $15,
       profession = $16,
       faith = $17::faith_type,
       mother_tongue = $18,
       family_structure = $19::family_type,
       family_involvement = $20::family_involvement_type,
       diet = $21::diet_type,
       drinking = $22::drinking_type,
       smoking = $23::smoking_type,
       marriage_timeline = $24::marriage_timeline_type,
       kids_preference = $25::kids_preference_type,
       willing_to_relocate = $26,
       work_mode = $27::work_mode_type,
       open_to_inter_faith = $28,
       interests = $29,
       profile_extras = $30::jsonb,
       is_live = TRUE,
       is_paused = FALSE,
       updated_at = NOW()
     WHERE uid = $1`,
    [
      uid,
      profile.display_name,
      profile.gender,
      profile.city,
      profile.home_state,
      profile.marital_status,
      profile.prompt_1_q,
      profile.prompt_1_a,
      profile.prompt_2_q,
      profile.prompt_2_a,
      profile.prompt_3_q,
      profile.prompt_3_a,
      profile.photo_urls,
      profile.education_level,
      profile.field_of_work,
      profile.profession,
      profile.faith,
      profile.mother_tongue,
      profile.family_structure,
      profile.family_involvement,
      profile.diet,
      profile.drinking,
      profile.smoking,
      profile.marriage_timeline,
      profile.kids_preference,
      profile.willing_to_relocate,
      profile.work_mode,
      profile.open_to_inter_faith,
      profile.interests,
      JSON.stringify(profile.profile_extras),
    ]
  );

  await client.query(
    `INSERT INTO preferences(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`,
    [uid]
  );

  await client.query(
    `UPDATE preferences SET
       pref_age_min = $2,
       pref_age_max = $3,
       db_gender = $4::gender_type[],
       updated_at = NOW()
     WHERE uid = $1`,
    [uid, preferences.pref_age_min, preferences.pref_age_max, preferences.db_gender]
  );

  await client.query(
    `INSERT INTO user_weight_maps(uid, status, source, weight_map, quiz_answers)
     VALUES ($1, 'skipped', 'community_default', $2::jsonb, '{}'::jsonb)
     ON CONFLICT(uid) DO UPDATE SET
       status = 'skipped',
       source = 'community_default',
       weight_map = EXCLUDED.weight_map,
       quiz_answers = '{}'::jsonb,
       updated_at = NOW()`,
    [uid, JSON.stringify(weightMap)]
  );

  const { rows } = await client.query(`SELECT * FROM profiles WHERE uid = $1`, [uid]);
  return upsertTrustScore(client, uid, rows[0], {
    trustScoreOverride: payload.targetTrustScore,
  });
}

function readManifest() {
  try {
    return JSON.parse(require("node:fs").readFileSync(MANIFEST_PATH, "utf8"));
  } catch {
    return { createdAt: null, viewerUid: null, users: [] };
  }
}

function writeManifest(manifest) {
  require("node:fs").writeFileSync(MANIFEST_PATH, `${JSON.stringify(manifest, null, 2)}\n`);
}

async function listTestUsersFromDb(viewerUid = null) {
  const pool = getPool();
  const params = [];
  let where = `p.profile_extras->>'is_test_user' = 'true'`;
  if (viewerUid) {
    params.push(viewerUid);
    where += ` AND p.profile_extras->>'seeded_for_viewer_uid' = $1`;
  }
  const { rows } = await pool.query(
    `SELECT u.uid, u.phone, p.display_name, p.gender, u.verified_age, p.diet, p.kids_preference
     FROM users u
     JOIN profiles p ON p.uid = u.uid
     WHERE ${where}
     ORDER BY u.phone ASC`,
    params
  );
  return rows;
}

module.exports = {
  MANIFEST_PATH,
  buildProfilePayload,
  loadViewer,
  loadViewerContext,
  summarizePartnerPlan,
  resolveWeightMap,
  insertPostgresUser,
  partnerGenderForIndex,
  testPhoneE164,
  testPhoneDisplay,
  readManifest,
  writeManifest,
  listTestUsersFromDb,
  normalizePhone,
  scenarioIdForIndex,
  describeScenario,
};
