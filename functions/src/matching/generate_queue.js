const { query } = require("../db");
const { scoreCandidate, RECENCY_DAYS } = require("./score_candidate");

function inferOppositeGender(gender) {
  const g = String(gender || "").toLowerCase();
  if (g === "man") return ["woman"];
  if (g === "woman") return ["man"];
  return ["man", "woman", "non_binary", "prefer_not_to_say"];
}

async function fetchPriorShowCounts(viewerUid, candidateUids) {
  if (candidateUids.length === 0) return {};
  const result = await query(
    `SELECT profile_uid, COUNT(*)::int AS show_count
     FROM daily_queue
     WHERE uid = $1
       AND profile_uid = ANY($2::text[])
       AND queue_date >= CURRENT_DATE - $3::int
     GROUP BY profile_uid`,
    [viewerUid, candidateUids, RECENCY_DAYS]
  );
  const map = {};
  for (const row of result.rows) {
    map[row.profile_uid] = row.show_count;
  }
  return map;
}

async function fetchCandidatePool(viewerUid) {
  const viewerResult = await query(
    `SELECT p.*, pref.pref_age_min, pref.pref_age_max, pref.db_gender,
            u.verified_age, ts.score AS trust_score
     FROM profiles p
     JOIN users u ON u.uid = p.uid
     LEFT JOIN preferences pref ON pref.uid = p.uid
     LEFT JOIN trust_scores ts ON ts.uid = p.uid
     WHERE p.uid = $1`,
    [viewerUid]
  );
  if (viewerResult.rowCount === 0) return { viewer: null, candidates: [] };
  const viewer = viewerResult.rows[0];

  const genderFilter =
    viewer.db_gender && viewer.db_gender.length > 0
      ? viewer.db_gender
      : inferOppositeGender(viewer.gender);

  const ageMin = viewer.pref_age_min ?? 21;
  const ageMax = viewer.pref_age_max ?? 35;

  const candidatesResult = await query(
    `SELECT p.*, u.verified_age, ts.score AS trust_score
     FROM profiles p
     JOIN users u ON u.uid = p.uid
     LEFT JOIN trust_scores ts ON ts.uid = p.uid
     WHERE p.uid != $1
       AND p.is_live = TRUE
       AND p.is_paused = FALSE
       AND u.account_status = 'active'
       AND u.verified_age BETWEEN $2 AND $3
       AND p.gender = ANY($4::gender_type[])
       AND p.uid NOT IN (
         SELECT target_uid FROM interactions
         WHERE actor_uid = $1 AND type IN ('passed', 'blocked')
       )
       AND p.uid NOT IN (
         SELECT blocked_uid FROM blocked_users WHERE blocker_uid = $1
       )
       AND p.uid NOT IN (
         SELECT blocker_uid FROM blocked_users WHERE blocked_uid = $1
       )
     LIMIT 500`,
    [viewerUid, ageMin, ageMax, genderFilter]
  );

  return { viewer, candidates: candidatesResult.rows };
}

async function generateQueueForUser(viewerUid, weightMapRow, queueDate = null) {
  const { viewer, candidates } = await fetchCandidatePool(viewerUid);
  if (!viewer || candidates.length === 0) {
    return [];
  }

  const weightMap =
    weightMapRow?.weight_map && typeof weightMapRow.weight_map === "object"
      ? weightMapRow.weight_map
      : { version: 1, fields: {} };
  const quizAnswers = weightMapRow?.quiz_answers || {};

  const candidateUids = candidates.map((c) => c.uid);
  const priorShows = await fetchPriorShowCounts(viewerUid, candidateUids);

  const scored = [];
  for (const candidate of candidates) {
    const result = scoreCandidate({
      viewerProfile: viewer,
      candidateProfile: candidate,
      weightMap,
      candidateTrustScore: candidate.trust_score || 0,
      priorShowCount: priorShows[candidate.uid] || 0,
      quizAnswers,
    });
    if (!result.excluded) {
      scored.push({ candidate, ...result });
    }
  }

  scored.sort((a, b) => {
    if (b.compatibilityScore !== a.compatibilityScore) {
      return b.compatibilityScore - a.compatibilityScore;
    }
    return (b.candidate.trust_score || 0) - (a.candidate.trust_score || 0);
  });

  const top5 = scored.slice(0, 5);
  const date = queueDate || new Date().toISOString().slice(0, 10);

  await query(
    `DELETE FROM daily_queue WHERE uid = $1 AND queue_date = $2::date`,
    [viewerUid, date]
  );

  const rows = [];
  for (let i = 0; i < top5.length; i++) {
    const item = top5[i];
    const insert = await query(
      `INSERT INTO daily_queue(
         uid, profile_uid, queue_date, position,
         compatibility_score, score_breakdown,
         match_reason_field, match_reason_label
       ) VALUES ($1, $2, $3::date, $4, $5, $6::jsonb, $7, $8)
       RETURNING *`,
      [
        viewerUid,
        item.candidate.uid,
        date,
        i + 1,
        item.compatibilityScore,
        JSON.stringify(item.scoreBreakdown),
        item.matchReasonField,
        item.matchReasonLabel,
      ]
    );
    rows.push(insert.rows[0]);
  }

  return rows;
}

async function generateDailyQueueForAllUsers() {
  const users = await query(
    `SELECT wm.uid, wm.weight_map, wm.quiz_answers
     FROM user_weight_maps wm
     JOIN profiles p ON p.uid = wm.uid
     WHERE wm.status IN ('completed', 'skipped')
       AND p.is_live = TRUE
       AND p.is_paused = FALSE`
  );

  let generated = 0;
  for (const row of users.rows) {
    await generateQueueForUser(row.uid, row);
    generated += 1;
  }
  return { generated };
}

module.exports = {
  generateQueueForUser,
  generateDailyQueueForAllUsers,
  fetchCandidatePool,
};
