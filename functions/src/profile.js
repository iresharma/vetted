const { HttpsError } = require("firebase-functions/v2/https");

const profileAllowedKeys = [
  "display_name",
  "gender",
  "city",
  "home_state",
  "height_cm",
  "profession",
  "company",
  "education_level",
  "college",
  "income_bracket",
  "work_mode",
  "faith",
  "community",
  "mother_tongue",
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
];

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

function buildDynamicUpdate({ table, keyColumn, keyValue, payload, touchUpdatedAt }) {
  const keys = Object.keys(payload);
  const setFragments = [];
  const values = [];

  keys.forEach((key, index) => {
    setFragments.push(`${key} = $${index + 1}`);
    values.push(payload[key]);
  });

  if (touchUpdatedAt) {
    setFragments.push("updated_at = NOW()");
  }

  values.push(keyValue);
  const sql = `UPDATE ${table} SET ${setFragments.join(", ")} WHERE ${keyColumn} = $${values.length}`;
  return { sql, values };
}

module.exports = {
  profileAllowedKeys,
  preferenceAllowedKeys,
  normalizePayload,
  buildDynamicUpdate,
};
