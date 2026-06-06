/** Required DB columns for is_live (21 fields — mirrors profile.json required_for_live). */
const REQUIRED_FOR_LIVE = [
  "display_name",
  "gender",
  "city",
  "marital_status",
  "prompt_1_a",
  "prompt_2_a",
  "prompt_3_a",
  "photo_urls",
  "education_level",
  "field_of_work",
  "profession",
  "faith",
  "mother_tongue",
  "family_structure",
  "family_involvement",
  "diet",
  "drinking",
  "smoking",
  "marriage_timeline",
  "kids_preference",
  "willing_to_relocate",
];

const REQUIRED_UI_TO_DB = {
  prompt_1: "prompt_1_a",
  prompt_2: "prompt_2_a",
  prompt_3: "prompt_3_a",
  job_title: "profession",
  wants_children: "kids_preference",
  partner_search_approach: null,
};

const OPTIONAL_COLUMN_KEYS = [
  "home_state",
  "height_cm",
  "body_type",
  "has_children",
  "college",
  "company",
  "employment_type",
  "work_mode",
  "income_bracket",
  "religiosity",
  "community",
  "sub_caste",
  "languages_spoken",
  "horoscope_matters",
  "manglik_status",
  "rashi",
  "nakshatra",
  "gotra",
  "birth_time",
  "birth_place",
  "living_arrangement_post_marriage",
  "father_occupation",
  "mother_occupation",
  "siblings",
  "family_location",
  "open_to_inter_faith",
  "open_to_inter_community",
  "interests",
];

const EXTRAS_KEYS = [
  "weekend_vibe",
  "sleep_schedule",
  "travel_frequency",
  "exercise_frequency",
  "pet_preference",
  "social_media_presence",
  "mbti",
  "love_language",
  "partner_search_approach",
  "spouse_working_preference",
  "disability",
];

const PROFILE_TRUST_MAX = 150;
const BEHAVIOR_TRUST_MAX = 50;
const TRUST_SCORE_MAX = 200;
const REPORT_PENALTY = 25;

function isFilled(value) {
  if (value == null) return false;
  if (Array.isArray(value)) return value.length > 0;
  if (typeof value === "boolean") return true;
  if (typeof value === "number") return true;
  if (typeof value === "string") return value.trim().length > 0;
  if (typeof value === "object") return Object.keys(value).length > 0;
  return false;
}

function isRequiredFilled(profile, extras, key) {
  const val = getFieldValue(profile, extras, key);
  if (key === "photo_urls") return Array.isArray(val) && val.length >= 3;
  return isFilled(val);
}

function getFieldValue(profile, extras, dbKey) {
  if (dbKey === "profile_extras") return null;
  if (Object.prototype.hasOwnProperty.call(profile, dbKey)) {
    return profile[dbKey];
  }
  if (extras && Object.prototype.hasOwnProperty.call(extras, dbKey)) {
    return extras[dbKey];
  }
  return null;
}

function roundPts(value) {
  return Math.round(value * 10) / 10;
}

function computeIsLive(profileRow) {
  const profile = profileRow || {};
  const extras =
    profile.profile_extras && typeof profile.profile_extras === "object"
      ? profile.profile_extras
      : {};

  return REQUIRED_FOR_LIVE.every((key) => isRequiredFilled(profile, extras, key));
}

/**
 * Profile Trust: max 150 (required 100 + optional 25 + extras 25).
 */
function computeProfileTrust(profileRow) {
  const profile = profileRow || {};
  const extras =
    profile.profile_extras && typeof profile.profile_extras === "object"
      ? profile.profile_extras
      : {};

  let requiredDone = 0;
  for (const key of REQUIRED_FOR_LIVE) {
    if (isRequiredFilled(profile, extras, key)) requiredDone += 1;
  }

  let optionalDone = 0;
  for (const key of OPTIONAL_COLUMN_KEYS) {
    if (isFilled(getFieldValue(profile, extras, key))) optionalDone += 1;
  }

  let extrasDone = 0;
  for (const key of EXTRAS_KEYS) {
    if (isFilled(extras[key])) extrasDone += 1;
  }

  const requiredPts = roundPts(
    REQUIRED_FOR_LIVE.length === 0
      ? 0
      : (requiredDone / REQUIRED_FOR_LIVE.length) * 100
  );
  const optionalPts = roundPts(
    OPTIONAL_COLUMN_KEYS.length === 0
      ? 0
      : (optionalDone / OPTIONAL_COLUMN_KEYS.length) * 25
  );
  const extrasPts = roundPts(
    EXTRAS_KEYS.length === 0 ? 0 : (extrasDone / EXTRAS_KEYS.length) * 25
  );
  const profilePoints = Math.min(
    PROFILE_TRUST_MAX,
    Math.round(requiredPts + optionalPts + extrasPts)
  );
  const isLive = computeIsLive(profileRow);

  return {
    requiredPts,
    optionalPts,
    extrasPts,
    profilePoints,
    isLive,
    requiredDone,
    optionalDone,
    extrasDone,
  };
}

/**
 * Behavior Trust: max 50 from app usage with other users and events.
 */
function computeBehaviorTrust(trustRow, mutualMatchCount = 0) {
  const row = trustRow || {};
  const eventsAttended = Number(row.events_attended || 0);
  const responseRatePct = Number(row.response_rate_pct ?? 100);
  const positiveFeedback = Number(row.positive_feedback_count || 0);
  const matches = Number(
    mutualMatchCount > 0 ? mutualMatchCount : row.mutual_match_count || 0
  );

  const eventsPts = Math.min(eventsAttended, 4) * 5;
  const matchesPts = Math.min(matches, 5) * 3;
  const responsePts = Math.min(10, Math.round(responseRatePct / 10));
  const feedbackPts = Math.min(positiveFeedback, 5);

  const behaviorPoints = Math.min(
    BEHAVIOR_TRUST_MAX,
    eventsPts + matchesPts + responsePts + feedbackPts
  );

  return {
    behaviorPoints,
    eventsPts,
    matchesPts,
    responsePts,
    feedbackPts,
  };
}

function computeTrustTier(score) {
  if (score >= 150) return "elite";
  if (score >= 100) return "highly_trusted";
  return "trusted";
}

const FIELD_LABELS = {
  display_name: "Display name",
  gender: "Gender",
  city: "Current city",
  marital_status: "Marital status",
  prompt_1_a: "Prompt 1",
  prompt_2_a: "Prompt 2",
  prompt_3_a: "Prompt 3",
  photo_urls: "Photos (3+ required)",
  education_level: "Education level",
  field_of_work: "Field of work",
  profession: "Job title",
  faith: "Faith",
  mother_tongue: "Mother tongue",
  family_structure: "Family structure",
  family_involvement: "Family involvement",
  diet: "Diet",
  drinking: "Drinking",
  smoking: "Smoking",
  marriage_timeline: "Marriage timeline",
  kids_preference: "Kids preference",
  willing_to_relocate: "Willing to relocate",
  home_state: "Hometown",
  height_cm: "Height",
  body_type: "Body type",
  has_children: "Children",
  college: "College",
  company: "Company",
  employment_type: "Employment type",
  work_mode: "Work mode",
  income_bracket: "Income bracket",
  religiosity: "Religiosity",
  community: "Community",
  sub_caste: "Sub-caste",
  languages_spoken: "Languages spoken",
  horoscope_matters: "Horoscope matters",
  manglik_status: "Manglik status",
  rashi: "Rashi",
  nakshatra: "Nakshatra",
  gotra: "Gotra",
  birth_time: "Birth time",
  birth_place: "Birth place",
  living_arrangement_post_marriage: "Living after marriage",
  father_occupation: "Father's occupation",
  mother_occupation: "Mother's occupation",
  siblings: "Siblings",
  family_location: "Family location",
  open_to_inter_faith: "Open to inter-faith",
  open_to_inter_community: "Open to inter-community",
  interests: "Interests",
  weekend_vibe: "Weekend vibe",
  sleep_schedule: "Sleep schedule",
  travel_frequency: "Travel frequency",
  exercise_frequency: "Exercise frequency",
  pet_preference: "Pet preference",
  social_media_presence: "Social media",
  mbti: "MBTI",
  love_language: "Love language",
  partner_search_approach: "Partner search approach",
  spouse_working_preference: "Spouse working preference",
  disability: "Disability",
};

function fieldLabel(key) {
  return FIELD_LABELS[key] || key.replace(/_/g, " ");
}

function buildProfileSectionItems(keys, profile, extras, maxPoints, checkFilled) {
  const perField = keys.length === 0 ? 0 : maxPoints / keys.length;
  const items = keys.map((key) => {
    const filled = checkFilled(key);
    const pointsPossible = roundPts(perField);
    const pointsEarned = filled ? pointsPossible : 0;
    return {
      key,
      label: fieldLabel(key),
      filled,
      pointsEarned,
      pointsPossible,
    };
  });
  const pointsEarned = roundPts(
    items.reduce((sum, item) => sum + item.pointsEarned, 0)
  );
  return { items, pointsEarned, pointsMax: maxPoints };
}

/**
 * Detailed profile trust breakdown for the trust report UI.
 */
function computeProfileBreakdown(profileRow) {
  const profile = profileRow || {};
  const extras =
    profile.profile_extras && typeof profile.profile_extras === "object"
      ? profile.profile_extras
      : {};

  const required = buildProfileSectionItems(
    REQUIRED_FOR_LIVE,
    profile,
    extras,
    100,
    (key) => isRequiredFilled(profile, extras, key)
  );
  const optional = buildProfileSectionItems(
    OPTIONAL_COLUMN_KEYS,
    profile,
    extras,
    25,
    (key) => isFilled(getFieldValue(profile, extras, key))
  );
  const extrasSection = buildProfileSectionItems(
    EXTRAS_KEYS,
    profile,
    extras,
    25,
    (key) => isFilled(extras[key])
  );

  const sortItems = (items) =>
    [...items].sort((a, b) => Number(a.filled) - Number(b.filled));

  const sections = [
    {
      id: "required",
      label: "Required fields",
      description: `${REQUIRED_FOR_LIVE.length} fields · up to 100 pts`,
      pointsEarned: required.pointsEarned,
      pointsMax: required.pointsMax,
      items: sortItems(required.items),
    },
    {
      id: "optional",
      label: "Optional details",
      description: `${OPTIONAL_COLUMN_KEYS.length} fields · up to 25 pts`,
      pointsEarned: optional.pointsEarned,
      pointsMax: optional.pointsMax,
      items: sortItems(optional.items),
    },
    {
      id: "extras",
      label: "Personality extras",
      description: `${EXTRAS_KEYS.length} fields · up to 25 pts`,
      pointsEarned: extrasSection.pointsEarned,
      pointsMax: extrasSection.pointsMax,
      items: sortItems(extrasSection.items),
    },
  ];

  const total = Math.min(
    PROFILE_TRUST_MAX,
    Math.round(
      required.pointsEarned + optional.pointsEarned + extrasSection.pointsEarned
    )
  );

  return { total, max: PROFILE_TRUST_MAX, sections };
}

/**
 * Detailed behavior trust breakdown for the trust report UI.
 */
function computeBehaviorBreakdown(trustRow, mutualMatchCount = 0) {
  const row = trustRow || {};
  const eventsAttended = Number(row.events_attended || 0);
  const responseRatePct = Number(row.response_rate_pct ?? 100);
  const positiveFeedback = Number(row.positive_feedback_count || 0);
  const matches = Number(
    mutualMatchCount > 0 ? mutualMatchCount : row.mutual_match_count || 0
  );

  const eventsPts = Math.min(eventsAttended, 4) * 5;
  const matchesPts = Math.min(matches, 5) * 3;
  const responsePts = Math.min(10, Math.round(responseRatePct / 10));
  const feedbackPts = Math.min(positiveFeedback, 5);
  const total = Math.min(
    BEHAVIOR_TRUST_MAX,
    eventsPts + matchesPts + responsePts + feedbackPts
  );

  return {
    total,
    max: BEHAVIOR_TRUST_MAX,
    items: [
      {
        id: "events",
        label: "Events attended",
        description: "5 pts per event · max 4 events",
        currentValue: `${eventsAttended} of 4`,
        pointsEarned: eventsPts,
        pointsMax: 20,
      },
      {
        id: "matches",
        label: "Mutual matches",
        description: "3 pts per match · max 5 matches",
        currentValue: `${matches} of 5`,
        pointsEarned: matchesPts,
        pointsMax: 15,
      },
      {
        id: "response_rate",
        label: "Response rate",
        description: "1 pt per 10% response rate · max 10 pts",
        currentValue: `${Math.round(responseRatePct)}%`,
        pointsEarned: responsePts,
        pointsMax: 10,
      },
      {
        id: "feedback",
        label: "Positive feedback",
        description: "1 pt per feedback · max 5 pts",
        currentValue: `${positiveFeedback} of 5`,
        pointsEarned: feedbackPts,
        pointsMax: 5,
      },
    ],
  };
}

function clampScore(value) {
  return Math.max(0, Math.min(TRUST_SCORE_MAX, Math.round(value)));
}

/**
 * Total Trust Score: profile (max 150) + behavior (max 50) − report penalties.
 */
function computeTrustScore({ profileRow, trustRow, reportsCount = 0, mutualMatchCount = 0 }) {
  const profile = computeProfileTrust(profileRow);
  const behavior = computeBehaviorTrust(trustRow, mutualMatchCount);
  const raw =
    profile.profilePoints +
    behavior.behaviorPoints -
    Number(reportsCount || 0) * REPORT_PENALTY;
  const trustScore = clampScore(raw);
  const trustTier = computeTrustTier(trustScore);

  return {
    trustScore,
    trustTier,
    profilePoints: profile.profilePoints,
    behaviorPoints: behavior.behaviorPoints,
    isLive: profile.isLive,
    ...profile,
    ...behavior,
  };
}

/** @deprecated Use computeTrustScore — kept for transitional imports. */
function computeCompleteness(profileRow) {
  const result = computeTrustScore({ profileRow, trustRow: {}, reportsCount: 0 });
  return {
    completenessPct: result.trustScore,
    isLive: result.isLive,
    trustScore: result.trustScore,
    trustTier: result.trustTier,
    profilePoints: result.profilePoints,
    behaviorPoints: result.behaviorPoints,
  };
}

module.exports = {
  REQUIRED_FOR_LIVE,
  REQUIRED_UI_TO_DB,
  OPTIONAL_COLUMN_KEYS,
  EXTRAS_KEYS,
  PROFILE_TRUST_MAX,
  BEHAVIOR_TRUST_MAX,
  TRUST_SCORE_MAX,
  REPORT_PENALTY,
  isFilled,
  computeIsLive,
  computeProfileTrust,
  computeBehaviorTrust,
  computeTrustTier,
  computeTrustScore,
  computeCompleteness,
  computeProfileBreakdown,
  computeBehaviorBreakdown,
  FIELD_LABELS,
};
