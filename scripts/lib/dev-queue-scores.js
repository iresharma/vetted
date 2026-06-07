const { matchReasonLabel: labelForField } = require("../../functions/src/matching/field_registry");

const DEFAULT_DEV_SCORES = [100, 92, 85, 78, 70];

const FALLBACK_BREAKDOWN_FIELDS = [
  "city",
  "marriage_timeline",
  "diet",
  "faith",
  "family_involvement",
  "wants_children",
  "education_level",
];

function parseTargetScores(raw) {
  if (!raw || raw === true) return DEFAULT_DEV_SCORES;
  const parts = String(raw)
    .split(",")
    .map((part) => Number.parseInt(part.trim(), 10))
    .filter((score) => Number.isFinite(score) && score >= 0 && score <= 100);
  if (parts.length === 0) {
    throw new Error("Provide comma-separated scores between 0 and 100, e.g. --scores 100,88,82,76,70");
  }
  return parts;
}

function scaleBreakdown(existingBreakdown, targetScore, currentScore) {
  const entries = Object.entries(
    existingBreakdown && typeof existingBreakdown === "object" ? existingBreakdown : {}
  );

  if (entries.length === 0) {
    return buildSyntheticBreakdown(targetScore);
  }

  // Keep real per-field alignment from the matcher. Only the headline
  // compatibility_score is dev-spread; flattening breakdown to targetScore
  // made every tile show the same number.
  const preserved = {};
  const meta = {};
  for (const [fieldId, value] of entries) {
    if (fieldId.startsWith("_")) {
      meta[fieldId] = value;
      continue;
    }
    const numeric = Number(value);
    if (!Number.isFinite(numeric)) continue;
    preserved[fieldId] = Math.max(0, Math.min(100, Math.round(numeric)));
  }

  if (Object.keys(preserved).length === 0) {
    return buildSyntheticBreakdown(targetScore);
  }

  if (meta._computedOverall == null && Number.isFinite(currentScore)) {
    meta._computedOverall = Math.round(currentScore);
  }

  return { ...preserved, ...meta };
}

function buildSyntheticBreakdown(targetScore) {
  const breakdown = {};
  FALLBACK_BREAKDOWN_FIELDS.forEach((fieldId, index) => {
    const jitter = [0, -4, 4, -8, 6, -2, 3][index % 7];
    breakdown[fieldId] = Math.max(0, Math.min(100, targetScore + jitter));
  });
  return breakdown;
}

function topBreakdownField(breakdown) {
  let topField = null;
  let topScore = -1;
  for (const [fieldId, value] of Object.entries(breakdown)) {
    if (fieldId.startsWith("_")) continue;
    const numeric = Number(value);
    if (!Number.isFinite(numeric) || numeric <= topScore) continue;
    topScore = numeric;
    topField = fieldId;
  }
  return topField;
}

async function applyDevScoreSpread(pool, viewerUid, targetScores, queueDate = null) {
  const date = queueDate || new Date().toISOString().slice(0, 10);
  const result = await pool.query(
    `SELECT id, position, compatibility_score, score_breakdown
     FROM daily_queue
     WHERE uid = $1 AND queue_date = $2::date
     ORDER BY position ASC`,
    [viewerUid, date]
  );

  if (result.rowCount === 0) return [];

  const updated = [];

  for (let i = 0; i < result.rows.length; i += 1) {
    const row = result.rows[i];
    const targetScore =
      targetScores[i] ?? targetScores[targetScores.length - 1] ?? row.compatibility_score;
    const scoreBreakdown = scaleBreakdown(
      row.score_breakdown,
      targetScore,
      row.compatibility_score
    );
    const matchReasonField = topBreakdownField(scoreBreakdown);
    const matchReasonLabelText = matchReasonField
      ? labelForField(matchReasonField, null, null)
      : null;

    await pool.query(
      `UPDATE daily_queue
       SET compatibility_score = $2,
           score_breakdown = $3::jsonb,
           match_reason_field = $4,
           match_reason_label = $5
       WHERE id = $1`,
      [row.id, targetScore, JSON.stringify(scoreBreakdown), matchReasonField, matchReasonLabelText]
    );

    updated.push({
      position: row.position,
      score: targetScore,
      matchReasonField,
    });
  }

  return updated;
}

module.exports = {
  DEFAULT_DEV_SCORES,
  parseTargetScores,
  applyDevScoreSpread,
};
