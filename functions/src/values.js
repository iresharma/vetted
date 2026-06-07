const { logger } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { query } = require("./db");
const { requireUid } = require("./auth");
const { neonDatabaseUrl } = require("./secrets");
const { buildWeightMapFromQuiz, syncPreferencesFromQuiz, mergeCommunityDefault, buildGlobalDefaultWeightMap } = require("./matching/weight_map");
const { normalizeQuizAnswers } = require("./matching/quiz_normalizer");
const { buildDynamicUpdate, preferenceTextArrayColumns, preferenceEnumArrayColumns } = require("./profile");

const callableDefaults = {
  region: "asia-south1",
  enforceAppCheck: true,
  cors: true,
  secrets: [neonDatabaseUrl],
};

function mapDbError(error) {
  if (error && error.code === "23505") {
    return new HttpsError("already-exists", "Duplicate value violates unique constraint.");
  }
  if (error && error.code === "22P02") {
    return new HttpsError("invalid-argument", "Invalid input value.");
  }
  logger.error("db_error", { message: error.message, code: error.code });
  return new HttpsError("internal", "Database operation failed.");
}

async function ensureWeightMapRow(uid) {
  await query(
    `INSERT INTO user_weight_maps(uid, status) VALUES ($1, 'pending')
     ON CONFLICT(uid) DO NOTHING`,
    [uid]
  );
}

async function loadCommunityDefault(faith, motherTongue) {
  const exact = await query(
    `SELECT weight_map FROM community_weight_defaults
     WHERE faith IS NOT DISTINCT FROM $1::faith_type
       AND mother_tongue IS NOT DISTINCT FROM $2
     LIMIT 1`,
    [faith || null, motherTongue || null]
  );
  if (exact.rowCount > 0) return exact.rows[0].weight_map;

  const faithOnly = await query(
    `SELECT weight_map FROM community_weight_defaults
     WHERE faith IS NOT DISTINCT FROM $1::faith_type
       AND mother_tongue IS NULL
     LIMIT 1`,
    [faith || null]
  );
  if (faithOnly.rowCount > 0) return faithOnly.rows[0].weight_map;

  const global = await query(
    `SELECT weight_map FROM community_weight_defaults
     WHERE faith IS NULL AND mother_tongue IS NULL
     LIMIT 1`
  );
  if (global.rowCount > 0) return global.rows[0].weight_map;

  return buildGlobalDefaultWeightMap();
}

async function syncPreferences(uid, quizAnswers) {
  const prefs = syncPreferencesFromQuiz(quizAnswers);
  if (Object.keys(prefs).length === 0) return;

  const { sql, values } = buildDynamicUpdate({
    table: "preferences",
    keyColumn: "uid",
    keyValue: uid,
    payload: prefs,
    touchUpdatedAt: true,
    textArrayColumns: preferenceTextArrayColumns,
    enumArrayColumns: preferenceEnumArrayColumns,
  });
  await query(sql, values);
}

exports.getValuesQuizStatus = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    await ensureWeightMapRow(uid);
    const result = await query(
      `SELECT status, source, updated_at FROM user_weight_maps WHERE uid = $1`,
      [uid]
    );
    const row = result.rows[0];
    return {
      status: row?.status || "pending",
      source: row?.source || null,
      updatedAt: row?.updated_at || null,
    };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.submitValuesQuiz = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const quizAnswers = normalizeQuizAnswers(request.data?.quizAnswers);
  if (!quizAnswers || typeof quizAnswers !== "object") {
    throw new HttpsError("invalid-argument", "quizAnswers object is required.");
  }

  try {
    await ensureWeightMapRow(uid);
    const weightMap = buildWeightMapFromQuiz(quizAnswers);

    await query(
      `UPDATE user_weight_maps
       SET status = 'completed',
           source = 'quiz',
           weight_map = $2::jsonb,
           quiz_answers = $3::jsonb,
           updated_at = NOW()
       WHERE uid = $1`,
      [uid, JSON.stringify(weightMap), JSON.stringify(quizAnswers)]
    );

    await syncPreferences(uid, quizAnswers);

    return { ok: true, status: "completed" };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.skipValuesQuiz = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    await ensureWeightMapRow(uid);

    const profileResult = await query(
      `SELECT faith, mother_tongue FROM profiles WHERE uid = $1`,
      [uid]
    );
    const profile = profileResult.rows[0] || {};
    const communityMap = await loadCommunityDefault(
      profile.faith,
      profile.mother_tongue
    );
    const weightMap = mergeCommunityDefault(communityMap);

    await query(
      `UPDATE user_weight_maps
       SET status = 'skipped',
           source = 'community_default',
           weight_map = $2::jsonb,
           quiz_answers = '{}'::jsonb,
           updated_at = NOW()
       WHERE uid = $1`,
      [uid, JSON.stringify(weightMap)]
    );

    return { ok: true, status: "skipped" };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

module.exports.loadCommunityDefault = loadCommunityDefault;
module.exports.ensureWeightMapRow = ensureWeightMapRow;
