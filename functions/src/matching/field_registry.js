/** Field metadata for values discovery scoring. */

const CLUSTERS = ["dealbreakers", "life_stage", "family", "lifestyle", "geography"];

const DEALBREAKER_FIELDS = [
  "diet",
  "drinking",
  "smoking",
  "faith",
  "marriage_timeline",
  "wants_children",
  "family_structure",
  "open_to_inter_faith",
];

const LIFE_STAGE_FIELDS = [
  "marriage_timeline",
  "education_level",
  "field_of_work",
  "work_mode",
  "partner_search_approach",
];

const FAMILY_FIELDS = [
  "family_involvement",
  "family_structure",
  "living_arrangement_post_marriage",
  "wants_children",
  "spouse_working_preference",
];

const LIFESTYLE_FIELDS = [
  "diet",
  "drinking",
  "smoking",
  "weekend_vibe",
  "exercise_frequency",
  "pet_preference",
  "travel_frequency",
];

const GEOGRAPHY_FIELDS = ["city", "willing_to_relocate", "home_state"];

const EXTRAS_FIELDS = new Set([
  "weekend_vibe",
  "exercise_frequency",
  "pet_preference",
  "travel_frequency",
  "partner_search_approach",
  "spouse_working_preference",
  "living_arrangement_post_marriage",
]);

const FIELD_DB_KEY = {
  wants_children: "kids_preference",
  job_title: "profession",
};

const TIMELINE_ORDER = [
  "within_6_months",
  "within_1_year",
  "1_to_2_years",
  "2_to_3_years",
  "exploring",
];

const MATCH_REASON_LABELS = {
  diet: "Same diet",
  drinking: "Similar drinking habits",
  smoking: "Similar smoking habits",
  faith: "Same faith",
  marriage_timeline: "Same marriage timeline",
  wants_children: "Aligned on children",
  family_structure: "Same family type",
  open_to_inter_faith: "Faith compatibility",
  education_level: "Similar education",
  field_of_work: "Similar career field",
  work_mode: "Compatible work style",
  partner_search_approach: "Same approach to dating",
  family_involvement: "Similar family involvement",
  living_arrangement_post_marriage: "Aligned living plans",
  spouse_working_preference: "Aligned on career expectations",
  weekend_vibe: "Similar weekend vibe",
  exercise_frequency: "Similar fitness habits",
  pet_preference: "Pet compatibility",
  travel_frequency: "Similar travel style",
  city: "Same city",
  willing_to_relocate: "Relocation flexibility",
  home_state: "Same hometown region",
};

const PASS_REASON_FIELDS = {
  different_timeline: "marriage_timeline",
  lifestyle_mismatch: "diet",
  family_values: "family_involvement",
  location: "city",
  not_my_type: null,
  other: null,
};

function clusterForField(fieldId) {
  if (DEALBREAKER_FIELDS.includes(fieldId)) return "dealbreakers";
  if (LIFE_STAGE_FIELDS.includes(fieldId)) return "life_stage";
  if (FAMILY_FIELDS.includes(fieldId)) return "family";
  if (LIFESTYLE_FIELDS.includes(fieldId)) return "lifestyle";
  if (GEOGRAPHY_FIELDS.includes(fieldId)) return "geography";
  return "lifestyle";
}

function dbKeyForField(fieldId) {
  return FIELD_DB_KEY[fieldId] || fieldId;
}

function getFieldValue(profileRow, fieldId) {
  if (!profileRow) return null;
  const dbKey = dbKeyForField(fieldId);
  if (EXTRAS_FIELDS.has(fieldId)) {
    const extras =
      profileRow.profile_extras && typeof profileRow.profile_extras === "object"
        ? profileRow.profile_extras
        : {};
    return extras[fieldId] ?? null;
  }
  return profileRow[dbKey] ?? null;
}

function matchReasonLabel(fieldId, viewerValue, candidateValue) {
  const base = MATCH_REASON_LABELS[fieldId] || "Shared values";
  if (fieldId === "marriage_timeline" && viewerValue === candidateValue) {
    return "Same marriage timeline";
  }
  if (fieldId === "city" && viewerValue && candidateValue) {
    const v = String(viewerValue).toLowerCase();
    const c = String(candidateValue).toLowerCase();
    if (v === c) return "Same city";
    return "Nearby location";
  }
  return base;
}

function allScorableFieldIds() {
  const set = new Set([
    ...DEALBREAKER_FIELDS,
    ...LIFE_STAGE_FIELDS,
    ...FAMILY_FIELDS,
    ...LIFESTYLE_FIELDS,
    ...GEOGRAPHY_FIELDS,
  ]);
  return [...set];
}

function buildDefaultFieldEntry(fieldId, mode = "soft", weight = 0.5) {
  return {
    mode,
    weight,
    cluster: clusterForField(fieldId),
  };
}

function buildGlobalDefaultWeightMap() {
  const fields = {};
  for (const fieldId of allScorableFieldIds()) {
    fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", 0.5);
  }
  fields.marriage_timeline.weight = 0.85;
  fields.family_involvement.weight = 0.75;
  fields.diet.weight = 0.7;
  fields.city.weight = 0.65;
  return { version: 1, fields };
}

module.exports = {
  CLUSTERS,
  DEALBREAKER_FIELDS,
  LIFE_STAGE_FIELDS,
  FAMILY_FIELDS,
  LIFESTYLE_FIELDS,
  GEOGRAPHY_FIELDS,
  EXTRAS_FIELDS,
  TIMELINE_ORDER,
  MATCH_REASON_LABELS,
  PASS_REASON_FIELDS,
  clusterForField,
  dbKeyForField,
  getFieldValue,
  matchReasonLabel,
  allScorableFieldIds,
  buildDefaultFieldEntry,
  buildGlobalDefaultWeightMap,
};
