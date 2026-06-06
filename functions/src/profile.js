const { HttpsError } = require("firebase-functions/v2/https");

const profileAllowedKeys = [
  "display_name",
  "gender",
  "city",
  "home_state",
  "height_cm",
  "body_type",
  "marital_status",
  "has_children",
  "profession",
  "field_of_work",
  "employment_type",
  "company",
  "education_level",
  "college",
  "income_bracket",
  "work_mode",
  "faith",
  "religiosity",
  "community",
  "sub_caste",
  "mother_tongue",
  "languages_spoken",
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
  "grew_up_abroad",
  "family_structure",
  "horoscope_matters",
  "diet",
  "drinking",
  "smoking",
  "marriage_timeline",
  "family_involvement",
  "kids_preference",
  "willing_to_relocate",
  "open_to_inter_faith",
  "open_to_inter_community",
  "prompt_1_q",
  "prompt_1_a",
  "prompt_2_q",
  "prompt_2_a",
  "prompt_3_q",
  "prompt_3_a",
  "photo_urls",
  "voice_note_url",
  "video_intro_url",
  "interests",
  "profile_extras",
];

const profileExtrasAllowedKeys = new Set([
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
  "grew_up_abroad_detail",
  "open_to_inter_faith_label",
  "open_to_inter_community_label",
  "willing_to_relocate_label",
]);

/** Postgres TEXT[] columns on profiles. */
const PROFILE_TEXT_ARRAY_COLUMNS = new Set([
  "photo_urls",
  "interests",
  "languages_spoken",
]);

const PREFERENCE_TEXT_ARRAY_COLUMNS = new Set([
  "db_city",
  "db_gender",
  "db_faith",
  "db_diet",
  "db_drinking",
  "db_smoking",
  "db_family_structure",
  "db_marriage_timeline",
]);

function parseTextArray(value) {
  if (value == null) return [];
  if (Array.isArray(value)) {
    return value.map((item) => String(item)).filter((item) => item.length > 0);
  }
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (trimmed === "" || trimmed === "{}") return [];
    if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
      const inner = trimmed.slice(1, -1).trim();
      if (!inner) return [];
      return inner.split(",").map((part) => part.replace(/^"(.*)"$/, "$1").trim());
    }
  }
  return [];
}

function coerceTextArray(value, fieldName) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item)).filter((item) => item.length > 0);
  }
  if (value == null) return [];
  throw new HttpsError(
    "invalid-argument",
    `${fieldName} must be an array of strings.`
  );
}

function mergeProfileExtras(existing, incoming) {
  const base =
    existing && typeof existing === "object" && !Array.isArray(existing)
      ? { ...existing }
      : {};
  if (!incoming || typeof incoming !== "object" || Array.isArray(incoming)) {
    return base;
  }
  for (const [key, value] of Object.entries(incoming)) {
    if (!profileExtrasAllowedKeys.has(key)) continue;
    if (value == null || value === "") {
      delete base[key];
    } else {
      base[key] = value;
    }
  }
  return base;
}

const preferenceAllowedKeys = [
  "pref_age_min",
  "pref_age_max",
  "pref_height_min_cm",
  "pref_height_max_cm",
  "db_city",
  "db_gender",
  "db_faith",
  "db_diet",
  "db_drinking",
  "db_smoking",
  "db_family_structure",
  "db_marriage_timeline",
  "rank_education",
  "rank_career",
  "rank_lifestyle",
  "rank_timeline",
  "rank_family_values",
  "rank_ambition",
  "rank_location_flexibility",
];

function normalizePayload(input, allowedKeys) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new HttpsError("invalid-argument", "Payload must be an object.");
  }
  const filtered = {};
  for (const key of allowedKeys) {
    if (Object.prototype.hasOwnProperty.call(input, key)) {
      filtered[key] = input[key];
    }
  }
  if (Object.keys(filtered).length === 0) {
    throw new HttpsError("invalid-argument", "No writable fields provided.");
  }
  return filtered;
}

function buildDynamicUpdate({
  table,
  keyColumn,
  keyValue,
  payload,
  touchUpdatedAt,
  textArrayColumns = new Set(),
  jsonbColumns = new Set(),
  timeColumns = new Set(),
  intColumns = new Set(),
  boolColumns = new Set(),
}) {
  const keys = Object.keys(payload);
  const setFragments = [];
  const values = [];

  keys.forEach((key, index) => {
    const placeholder = `$${index + 1}`;
    if (textArrayColumns.has(key)) {
      setFragments.push(`${key} = ${placeholder}::text[]`);
    } else if (jsonbColumns.has(key)) {
      setFragments.push(`${key} = ${placeholder}::jsonb`);
    } else if (timeColumns.has(key)) {
      setFragments.push(`${key} = ${placeholder}::time`);
    } else if (intColumns.has(key)) {
      setFragments.push(`${key} = ${placeholder}::smallint`);
    } else if (boolColumns.has(key)) {
      setFragments.push(`${key} = ${placeholder}::boolean`);
    } else {
      setFragments.push(`${key} = ${placeholder}`);
    }
    values.push(
      jsonbColumns.has(key) ? JSON.stringify(payload[key]) : payload[key]
    );
  });

  if (touchUpdatedAt) {
    setFragments.push("updated_at = NOW()");
  }

  values.push(keyValue);
  const sql = `UPDATE ${table} SET ${setFragments.join(", ")} WHERE ${keyColumn} = $${values.length}`;
  return { sql, values };
}

const PROFILE_BOOL_COLUMNS = new Set([
  "grew_up_abroad",
  "horoscope_matters",
  "willing_to_relocate",
  "open_to_inter_faith",
  "open_to_inter_community",
]);

const PROFILE_INT_COLUMNS = new Set(["height_cm"]);

const PROFILE_TIME_COLUMNS = new Set(["birth_time"]);

module.exports = {
  profileAllowedKeys,
  profileExtrasAllowedKeys,
  preferenceAllowedKeys,
  profileTextArrayColumns: PROFILE_TEXT_ARRAY_COLUMNS,
  preferenceTextArrayColumns: PREFERENCE_TEXT_ARRAY_COLUMNS,
  profileBoolColumns: PROFILE_BOOL_COLUMNS,
  profileIntColumns: PROFILE_INT_COLUMNS,
  profileTimeColumns: PROFILE_TIME_COLUMNS,
  parseTextArray,
  coerceTextArray,
  mergeProfileExtras,
  normalizePayload,
  buildDynamicUpdate,
};
