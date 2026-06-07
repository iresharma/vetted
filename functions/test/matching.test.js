const assert = require("node:assert/strict");
const { buildWeightMapFromQuiz, rankToWeights } = require("../src/matching/weight_map");
const { scoreCandidate } = require("../src/matching/score_candidate");
const { scoreField, passesHardFilter } = require("../src/matching/field_scorers");

function viewerProfile(overrides = {}) {
  return {
    uid: "viewer",
    gender: "man",
    city: "Bengaluru",
    faith: "hindu",
    diet: "vegetarian",
    drinking: "never",
    smoking: "never",
    marriage_timeline: "1_to_2_years",
    kids_preference: "want_kids",
    family_structure: "nuclear",
    family_involvement: "i_decide_they_know",
    education_level: "Master's",
    field_of_work: "Software & technology",
    work_mode: "hybrid",
    willing_to_relocate: true,
    profile_extras: {
      partner_search_approach: "Date first — get to know each other before deciding",
      weekend_vibe: ["Homebody — recharge at home", "Foodie — trying new places"],
    },
    ...overrides,
  };
}

function candidateProfile(overrides = {}) {
  return viewerProfile({ uid: "candidate", ...overrides });
}

// Quiz → weight map
const quizAnswers = {
  dealbreakers: {
    selected: ["diet", "smoking"],
    acceptable: { diet: ["vegetarian", "vegan"] },
  },
  lifeStage: { careerVsTimeline: 0.7 },
  family: {
    importance: {
      family_involvement: 5,
      family_structure: 4,
      wants_children: 5,
    },
  },
  lifestyle: {
    ranked: ["diet", "weekend_vibe", "drinking", "smoking", "exercise_frequency", "pet_preference", "travel_frequency"],
  },
  geography: { sameCityOnly: false, relocateImportance: 4 },
};

const weightMap = buildWeightMapFromQuiz(quizAnswers);
assert.equal(weightMap.fields.diet.mode, "hard");
assert.equal(weightMap.fields.smoking.mode, "hard");
assert.equal(weightMap.fields.drinking.mode, "soft");
assert.ok(weightMap.fields.marriage_timeline.weight > 0);

// Rank to weights
const ranks = rankToWeights(["a", "b", "c"], ["a", "b", "c"]);
assert.ok(Math.abs(ranks.a - 0.5) < 0.01);
assert.ok(Math.abs(ranks.b - 0.33) < 0.02);

// Hard filter exclusion
const excluded = scoreCandidate({
  viewerProfile: viewerProfile(),
  candidateProfile: candidateProfile({ diet: "non_vegetarian" }),
  weightMap,
  quizAnswers,
});
assert.equal(excluded.excluded, true);

// Soft scoring
const scored = scoreCandidate({
  viewerProfile: viewerProfile(),
  candidateProfile: candidateProfile(),
  weightMap,
  candidateTrustScore: 120,
  priorShowCount: 0,
  quizAnswers,
});
assert.equal(scored.excluded, false);
assert.ok(scored.compatibilityScore >= 70);
assert.ok(scored.matchReasonField);
assert.ok(scored.matchReasonLabel);

// Recency penalty
const penalized = scoreCandidate({
  viewerProfile: viewerProfile(),
  candidateProfile: candidateProfile(),
  weightMap,
  candidateTrustScore: 0,
  priorShowCount: 3,
  quizAnswers,
});
assert.ok(penalized.recencyPenalty >= 24);
assert.ok(penalized.compatibilityScore < scored.compatibilityScore);

// Field scorers
assert.equal(scoreField("marriage_timeline", viewerProfile(), candidateProfile()), 1);
assert.equal(
  scoreField(
    "marriage_timeline",
    viewerProfile({ marriage_timeline: "within_6_months" }),
    candidateProfile({ marriage_timeline: "exploring" })
  ),
  0
);

assert.equal(
  passesHardFilter(
    "diet",
    viewerProfile(),
    candidateProfile({ diet: "vegan" }),
    { dealbreakers: { acceptable: { diet: ["vegetarian", "vegan"] } } }
  ),
  true
);

const {
  buildDynamicUpdate,
  preferenceEnumArrayColumns,
  preferenceTextArrayColumns,
} = require("../src/profile");
const prefUpdate = buildDynamicUpdate({
  table: "preferences",
  keyColumn: "uid",
  keyValue: "u1",
  payload: { db_diet: ["vegetarian", "vegan"], db_city: ["Bengaluru"] },
  touchUpdatedAt: true,
  textArrayColumns: preferenceTextArrayColumns,
  enumArrayColumns: preferenceEnumArrayColumns,
});
assert.match(prefUpdate.sql, /db_diet = \$1::diet_type\[\]/);
assert.match(prefUpdate.sql, /db_city = \$2::text\[\]/);

console.log("matching.test.js: all assertions passed");
