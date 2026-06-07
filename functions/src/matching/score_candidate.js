const { scoreField, passesHardFilter } = require("./field_scorers");
const {
  getFieldValue,
  matchReasonLabel,
} = require("./field_registry");

const RECENCY_PENALTY_PER_SHOW = 8;
const RECENCY_PENALTY_CAP = 24;
const RECENCY_DAYS = 14;

function scoreCandidate({
  viewerProfile,
  candidateProfile,
  weightMap,
  candidateTrustScore = 0,
  priorShowCount = 0,
  quizAnswers = {},
}) {
  const fields = weightMap?.fields || {};
  const breakdown = {};
  let excluded = false;

  for (const [fieldId, entry] of Object.entries(fields)) {
    if (entry.mode !== "hard") continue;
    if (!passesHardFilter(fieldId, viewerProfile, candidateProfile, quizAnswers)) {
      excluded = true;
      break;
    }
  }

  if (excluded) {
    return {
      excluded: true,
      compatibilityScore: 0,
      scoreBreakdown: {},
      matchReasonField: null,
      matchReasonLabel: null,
    };
  }

  let weightedSum = 0;
  let weightTotal = 0;
  let topContribution = -1;
  let matchReasonField = null;

  for (const [fieldId, entry] of Object.entries(fields)) {
    if (entry.mode === "hard") continue;
    const weight = Number(entry.weight) || 0;
    if (weight <= 0) continue;

    const fieldScore = scoreField(fieldId, viewerProfile, candidateProfile);
    if (fieldScore == null) continue;

    const contribution = fieldScore * weight;
    breakdown[fieldId] = Math.round(fieldScore * 100);
    weightedSum += contribution;
    weightTotal += weight;

    if (contribution > topContribution) {
      topContribution = contribution;
      matchReasonField = fieldId;
    }
  }

  let rawScore = weightTotal > 0 ? (weightedSum / weightTotal) * 100 : 50;
  rawScore = Math.round(rawScore);

  const trustBonus = Math.min(5, Math.floor(candidateTrustScore / 40));
  const recencyPenalty = Math.min(
    RECENCY_PENALTY_CAP,
    priorShowCount * RECENCY_PENALTY_PER_SHOW
  );

  const compatibilityScore = Math.max(
    0,
    Math.min(100, rawScore + trustBonus - recencyPenalty)
  );

  if (trustBonus > 0) breakdown._trustBonus = trustBonus;
  if (recencyPenalty > 0) breakdown._recencyPenalty = recencyPenalty;
  breakdown._rawScore = rawScore;
  breakdown._computedOverall = compatibilityScore;

  const viewerVal = matchReasonField
    ? getFieldValue(viewerProfile, matchReasonField)
    : null;
  const candidateVal = matchReasonField
    ? getFieldValue(candidateProfile, matchReasonField)
    : null;

  return {
    excluded: false,
    compatibilityScore,
    rawScore,
    trustBonus,
    recencyPenalty,
    scoreBreakdown: breakdown,
    matchReasonField,
    matchReasonLabel: matchReasonField
      ? matchReasonLabel(matchReasonField, viewerVal, candidateVal)
      : null,
  };
}

module.exports = {
  scoreCandidate,
  RECENCY_PENALTY_PER_SHOW,
  RECENCY_PENALTY_CAP,
  RECENCY_DAYS,
};
