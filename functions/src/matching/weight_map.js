const {
  allScorableFieldIds,
  buildDefaultFieldEntry,
  buildGlobalDefaultWeightMap,
  clusterForField,
  DEALBREAKER_FIELDS,
  LIFE_STAGE_FIELDS,
  FAMILY_FIELDS,
  LIFESTYLE_FIELDS,
  GEOGRAPHY_FIELDS,
} = require("./field_registry");

function rankToWeights(fieldIds, rankedIds) {
  const n = rankedIds.length;
  const sum = (n * (n + 1)) / 2;
  const weights = {};
  rankedIds.forEach((fieldId, index) => {
    weights[fieldId] = (n - index) / sum;
  });
  for (const fieldId of fieldIds) {
    if (!weights[fieldId]) weights[fieldId] = 0.1 / fieldIds.length;
  }
  return weights;
}

function buildWeightMapFromQuiz(quizAnswers) {
  const fields = {};
  const global = buildGlobalDefaultWeightMap().fields;

  for (const fieldId of allScorableFieldIds()) {
    fields[fieldId] = { ...global[fieldId] };
  }

  const hardSelected = new Set(quizAnswers.dealbreakers?.selected || []);
  for (const fieldId of DEALBREAKER_FIELDS) {
    if (hardSelected.has(fieldId)) {
      fields[fieldId] = buildDefaultFieldEntry(fieldId, "hard", 0);
    } else {
      fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", 0.3);
    }
  }

  const lifeStageBias = Number(quizAnswers.lifeStage?.careerVsTimeline ?? 0.5);
  const lifeWeights = {};
  const timelineWeight = 0.3 + lifeStageBias * 0.5;
  const careerWeight = 0.3 + (1 - lifeStageBias) * 0.5;
  lifeWeights.marriage_timeline = timelineWeight;
  lifeWeights.education_level = careerWeight * 0.35;
  lifeWeights.field_of_work = careerWeight * 0.35;
  lifeWeights.work_mode = careerWeight * 0.2;
  lifeWeights.partner_search_approach = careerWeight * 0.1;
  const lifeSum = Object.values(lifeWeights).reduce((a, b) => a + b, 0);
  for (const [fieldId, w] of Object.entries(lifeWeights)) {
    const existing = fields[fieldId];
    if (existing?.mode === "hard") continue;
    fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", w / lifeSum);
  }

  const familyImportance = quizAnswers.family?.importance || {};
  const familyIds = FAMILY_FIELDS;
  let familyTotal = 0;
  for (const fieldId of familyIds) {
    const imp = Number(familyImportance[fieldId] ?? 3);
    const w = imp / 5;
    fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", w);
    familyTotal += w;
  }
  if (familyTotal > 0) {
    for (const fieldId of familyIds) {
      if (fields[fieldId]?.mode === "hard") continue;
      fields[fieldId].weight = fields[fieldId].weight / familyTotal;
    }
  }

  const lifestyleRank = quizAnswers.lifestyle?.ranked || LIFESTYLE_FIELDS;
  const lifestyleWeights = rankToWeights(LIFESTYLE_FIELDS, lifestyleRank);
  for (const [fieldId, w] of Object.entries(lifestyleWeights)) {
    const existing = fields[fieldId];
    if (existing?.mode === "hard") continue;
    fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", w);
  }

  const geo = quizAnswers.geography || {};
  if (geo.sameCityOnly) {
    fields.city = buildDefaultFieldEntry("city", "hard", 0);
  } else {
    fields.city = buildDefaultFieldEntry("city", "soft", 0.5);
  }
  fields.willing_to_relocate = buildDefaultFieldEntry(
    "willing_to_relocate",
    "soft",
    geo.relocateImportance != null ? Number(geo.relocateImportance) / 5 : 0.5
  );
  fields.home_state = buildDefaultFieldEntry("home_state", "soft", 0.3);

  const geoTotal =
    fields.city.weight + fields.willing_to_relocate.weight + fields.home_state.weight;
  fields.city.weight /= geoTotal;
  fields.willing_to_relocate.weight /= geoTotal;
  fields.home_state.weight /= geoTotal;

  return { version: 1, fields };
}

function syncPreferencesFromQuiz(quizAnswers) {
  const prefs = {};
  const hardSelected = new Set(quizAnswers.dealbreakers?.selected || []);
  const dbMapping = {
    diet: "db_diet",
    drinking: "db_drinking",
    smoking: "db_smoking",
    faith: "db_faith",
    marriage_timeline: "db_marriage_timeline",
    family_structure: "db_family_structure",
  };

  for (const [fieldId, prefKey] of Object.entries(dbMapping)) {
    if (hardSelected.has(fieldId)) {
      const acceptable = quizAnswers.dealbreakers?.acceptable?.[fieldId];
      if (Array.isArray(acceptable) && acceptable.length > 0) {
        prefs[prefKey] = acceptable;
      }
    }
  }

  if (quizAnswers.geography?.preferredCities?.length) {
    prefs.db_city = quizAnswers.geography.preferredCities;
  }

  return prefs;
}

function applyLearningDelta(weightMap, fieldId, delta, reason) {
  const map = JSON.parse(JSON.stringify(weightMap || { version: 1, fields: {} }));
  if (!map.fields) map.fields = {};
  if (!map.fields[fieldId]) {
    map.fields[fieldId] = buildDefaultFieldEntry(fieldId, "soft", 0.5);
  }
  const entry = map.fields[fieldId];
  if (entry.mode === "hard") return map;

  entry.weight = Math.min(1, Math.max(0.1, entry.weight + delta));
  map.learning_log = map.learning_log || [];
  map.learning_log.unshift({
    fieldId,
    delta,
    reason,
    at: new Date().toISOString(),
  });
  map.learning_log = map.learning_log.slice(0, 20);
  return map;
}

function mergeCommunityDefault(communityMap) {
  const base = buildGlobalDefaultWeightMap();
  if (!communityMap || !communityMap.fields) return base;
  const merged = { version: 1, fields: { ...base.fields } };
  for (const [fieldId, entry] of Object.entries(communityMap.fields)) {
    merged.fields[fieldId] = {
      ...buildDefaultFieldEntry(fieldId, entry.mode || "soft", entry.weight ?? 0.5),
      ...entry,
      cluster: entry.cluster || clusterForField(fieldId),
    };
  }
  return merged;
}

module.exports = {
  buildWeightMapFromQuiz,
  syncPreferencesFromQuiz,
  applyLearningDelta,
  mergeCommunityDefault,
  buildGlobalDefaultWeightMap,
  rankToWeights,
};
