const path = require("node:path");
const {
  getFieldValue,
  dbKeyForField,
  EXTRAS_FIELDS,
  TIMELINE_ORDER,
} = require(path.join(__dirname, "../../functions/src/matching/field_registry"));

const SCENARIO_COUNT = 5;

const SCENARIOS = [
  {
    id: 1,
    slug: "strong_match",
    label: "Strong match — aligned on most values",
    trustScore: 200,
  },
  {
    id: 2,
    slug: "timeline_gap",
    label: "Timeline gap — marriage timeline one step off",
    trustScore: 120,
  },
  {
    id: 3,
    slug: "location_gap",
    label: "Location gap — different city",
    trustScore: 80,
  },
  {
    id: 4,
    slug: "lifestyle_gap",
    label: "Lifestyle gap — weekend vibe and drinking differ",
    trustScore: 40,
  },
  {
    id: 5,
    slug: "mixed_gaps",
    label: "Mixed gaps — city, work style, and family involvement differ",
    trustScore: 0,
  },
];

const ALT_CITIES = ["Mumbai", "Delhi", "Hyderabad", "Pune", "Chennai", "Bengaluru"];

const WEEKEND_VIBE_OPPOSITE = [
  "Nightlife — bars and events",
  "Creative — museums and art",
];

function scenarioIdForIndex(index) {
  return ((index - 1) % SCENARIO_COUNT) + 1;
}

function describeScenario(scenarioId) {
  return SCENARIOS.find((row) => row.id === scenarioId) || SCENARIOS[0];
}

function trustScoreForScenario(scenarioId) {
  return describeScenario(scenarioId).trustScore;
}

function isHardField(fieldId, weightMapRow) {
  return weightMapRow?.weight_map?.fields?.[fieldId]?.mode === "hard";
}

function setProfileField(profile, fieldId, value) {
  if (value == null) return;
  if (EXTRAS_FIELDS.has(fieldId)) {
    profile.profile_extras = profile.profile_extras || {};
    profile.profile_extras[fieldId] = value;
    return;
  }
  profile[dbKeyForField(fieldId)] = value;
}

function setSoftField(profile, fieldId, value, viewerContext) {
  if (isHardField(fieldId, viewerContext.weightMapRow)) return;
  setProfileField(profile, fieldId, value);
}

function pickAlternate(current, options) {
  const normalized = String(current || "").toLowerCase();
  const alt = options.find((option) => String(option).toLowerCase() !== normalized);
  return alt || options[0];
}

function shiftTimeline(viewerValue, steps) {
  const normalized = String(viewerValue || "").toLowerCase();
  const index = TIMELINE_ORDER.indexOf(normalized);
  if (index < 0) return viewerValue;
  const next = Math.max(0, Math.min(TIMELINE_ORDER.length - 1, index + steps));
  return TIMELINE_ORDER[next];
}

function pickDifferentCity(viewerCity) {
  const normalized = String(viewerCity || "").toLowerCase();
  return ALT_CITIES.find((city) => city.toLowerCase() !== normalized) || "Mumbai";
}

/**
 * Vary soft fields so dev queue scores and breakdowns mirror production:
 * weighted overall, per-field differences, and trust bonus spread.
 */
function applyProdLikeMatchScenario(profile, viewerContext, scenarioId) {
  const { viewer } = viewerContext;
  const extras = profile.profile_extras || {};

  switch (scenarioId) {
    case 1:
      break;

    case 2:
      setSoftField(
        profile,
        "marriage_timeline",
        shiftTimeline(getFieldValue(viewer, "marriage_timeline"), 1),
        viewerContext
      );
      break;

    case 3:
      setSoftField(profile, "city", pickDifferentCity(viewer.city), viewerContext);
      break;

    case 4:
      profile.profile_extras = {
        ...extras,
        weekend_vibe: WEEKEND_VIBE_OPPOSITE,
      };
      setSoftField(
        profile,
        "drinking",
        pickAlternate(getFieldValue(viewer, "drinking"), [
          "never",
          "socially",
          "regularly",
        ]),
        viewerContext
      );
      break;

    case 5:
      setSoftField(profile, "city", pickDifferentCity(viewer.city), viewerContext);
      setSoftField(
        profile,
        "work_mode",
        pickAlternate(getFieldValue(viewer, "work_mode"), ["remote", "in_office", "hybrid"]),
        viewerContext
      );
      setSoftField(
        profile,
        "family_involvement",
        pickAlternate(getFieldValue(viewer, "family_involvement"), [
          "parents_leading",
          "i_decide_they_know",
          "private_for_now",
        ]),
        viewerContext
      );
      setSoftField(
        profile,
        "drinking",
        pickAlternate(getFieldValue(viewer, "drinking"), [
          "never",
          "socially",
          "regularly",
        ]),
        viewerContext
      );
      break;

    default:
      break;
  }
}

module.exports = {
  SCENARIO_COUNT,
  SCENARIOS,
  scenarioIdForIndex,
  describeScenario,
  trustScoreForScenario,
  applyProdLikeMatchScenario,
  isHardField,
};
