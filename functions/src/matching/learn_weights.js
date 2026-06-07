const { query } = require("../db");
const { applyLearningDelta } = require("./weight_map");
const { scoreField } = require("./field_scorers");
const { getFieldValue, PASS_REASON_FIELDS } = require("./field_registry");

async function learnWeightMapsForAllUsers() {
  const since = new Date();
  since.setDate(since.getDate() - 30);

  const interactions = await query(
    `SELECT i.actor_uid, i.target_uid, i.type, i.pass_reason, i.pass_reason_field,
            i.created_at,
            actor_p.uid AS actor_exists,
            target_p.uid AS target_exists
     FROM interactions i
     JOIN profiles actor_p ON actor_p.uid = i.actor_uid
     JOIN profiles target_p ON target_p.uid = i.target_uid
     WHERE i.created_at >= $1
       AND i.type IN ('passed', 'interested', 'matched')
     ORDER BY i.created_at ASC`,
    [since.toISOString()]
  );

  const updatesByUser = new Map();

  for (const row of interactions.rows) {
    const uid = row.actor_uid;
    if (!updatesByUser.has(uid)) {
      updatesByUser.set(uid, []);
    }
    updatesByUser.get(uid).push(row);
  }

  let updated = 0;
  for (const [uid, userInteractions] of updatesByUser) {
    const wmResult = await query(
      `SELECT weight_map, quiz_answers FROM user_weight_maps WHERE uid = $1`,
      [uid]
    );
    if (wmResult.rowCount === 0) continue;

    let weightMap = wmResult.rows[0].weight_map || { version: 1, fields: {} };
    const passCounts = {};

    for (const inter of userInteractions) {
      const targetProfile = await query(`SELECT * FROM profiles WHERE uid = $1`, [
        inter.target_uid,
      ]);
      const viewerProfile = await query(`SELECT * FROM profiles WHERE uid = $1`, [uid]);
      if (targetProfile.rowCount === 0 || viewerProfile.rowCount === 0) continue;

      const candidate = targetProfile.rows[0];
      const viewer = viewerProfile.rows[0];

      if (inter.type === "interested" || inter.type === "matched") {
        for (const fieldId of Object.keys(weightMap.fields || {})) {
          const fs = scoreField(fieldId, viewer, candidate);
          if (fs != null && fs >= 0.8) {
            weightMap = applyLearningDelta(weightMap, fieldId, 0.02, "positive_interaction");
          }
        }
      }

      if (inter.type === "passed") {
        let fieldId =
          inter.pass_reason_field ||
          PASS_REASON_FIELDS[inter.pass_reason] ||
          null;
        if (fieldId) {
          weightMap = applyLearningDelta(weightMap, fieldId, -0.03, "pass");
          passCounts[fieldId] = (passCounts[fieldId] || 0) + 1;
          if (passCounts[fieldId] >= 3 && weightMap.fields[fieldId]) {
            weightMap.fields[fieldId].mode = "hard";
          }
        }
      }
    }

    await query(
      `UPDATE user_weight_maps
       SET weight_map = $2::jsonb, source = 'learned', updated_at = NOW()
       WHERE uid = $1`,
      [uid, JSON.stringify(weightMap)]
    );
    updated += 1;
  }

  return { updated };
}

module.exports = { learnWeightMapsForAllUsers };
