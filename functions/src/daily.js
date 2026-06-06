const { logger } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { query } = require("./db");
const { requireUid } = require("./auth");
const { neonDatabaseUrl } = require("./secrets");
const { parseTextArray } = require("./profile");
const {
  generateQueueForUser,
  generateDailyQueueForAllUsers,
} = require("./matching/generate_queue");
const { learnWeightMapsForAllUsers } = require("./matching/learn_weights");
const { refreshTrustScore } = require("./registration");

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

function hydrateProfileSummary(row) {
  const extras =
    row.profile_extras && typeof row.profile_extras === "object"
      ? row.profile_extras
      : {};
  return {
    uid: row.uid,
    displayName: row.display_name,
    age: row.verified_age,
    city: row.city,
    profession: row.profession,
    faith: row.faith,
    motherTongue: row.mother_tongue,
    marriageTimeline: row.marriage_timeline,
    photoUrls: parseTextArray(row.photo_urls),
    trustScore: row.trust_score || 0,
    trustTier: row.trust_tier || "trusted",
    prompt1Q: row.prompt_1_q,
    prompt1A: row.prompt_1_a,
    prompt2Q: row.prompt_2_q,
    prompt2A: row.prompt_2_a,
    prompt3Q: row.prompt_3_q,
    prompt3A: row.prompt_3_a,
    interests: parseTextArray(row.interests),
    profileExtras: extras,
  };
}

exports.getDailyQueue = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    const queueResult = await query(
      `SELECT dq.*, p.*, u.verified_age, ts.score AS trust_score, ts.tier AS trust_tier
       FROM daily_queue dq
       JOIN profiles p ON p.uid = dq.profile_uid
       JOIN users u ON u.uid = p.uid
       LEFT JOIN trust_scores ts ON ts.uid = p.uid
       WHERE dq.uid = $1 AND dq.queue_date = CURRENT_DATE
       ORDER BY dq.position ASC`,
      [uid]
    );

    const entries = queueResult.rows.map((row) => ({
      id: row.id,
      position: row.position,
      compatibilityScore: row.compatibility_score,
      scoreBreakdown: row.score_breakdown || {},
      matchReasonField: row.match_reason_field,
      matchReasonLabel: row.match_reason_label,
      wasShown: row.was_shown,
      profile: hydrateProfileSummary(row),
    }));

    return { entries, queueDate: new Date().toISOString().slice(0, 10) };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.markDailyQueueShown = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const queueId = request.data?.queueId;
  if (!queueId) {
    throw new HttpsError("invalid-argument", "queueId is required.");
  }

  try {
    await query(
      `UPDATE daily_queue
       SET was_shown = TRUE, shown_at = NOW()
       WHERE id = $1 AND uid = $2`,
      [queueId, uid]
    );
    return { ok: true };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.recordDailyInteraction = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const { targetUid, type, passReason, passReasonField } = request.data || {};

  if (!targetUid || !type) {
    throw new HttpsError("invalid-argument", "targetUid and type are required.");
  }
  if (!["passed", "interested"].includes(type)) {
    throw new HttpsError("invalid-argument", "type must be passed or interested.");
  }
  if (targetUid === uid) {
    throw new HttpsError("invalid-argument", "Cannot interact with yourself.");
  }

  try {
    await query(
      `INSERT INTO interactions(actor_uid, target_uid, type, source, pass_reason, pass_reason_field)
       VALUES ($1, $2, $3::interaction_type, 'daily_queue', $4::pass_reason_type, $5)
       ON CONFLICT (actor_uid, target_uid)
       DO UPDATE SET
         type = EXCLUDED.type,
         source = EXCLUDED.source,
         pass_reason = EXCLUDED.pass_reason,
         pass_reason_field = EXCLUDED.pass_reason_field,
         updated_at = NOW()`,
      [
        uid,
        targetUid,
        type,
        passReason || null,
        passReasonField || null,
      ]
    );

    let isMutual = false;
    if (type === "interested") {
      const reverse = await query(
        `SELECT id FROM interactions
         WHERE actor_uid = $1 AND target_uid = $2 AND type = 'interested'`,
        [targetUid, uid]
      );
      if (reverse.rowCount > 0) {
        isMutual = true;
        await query(
          `UPDATE interactions
           SET type = 'matched', is_mutual = TRUE, matched_at = NOW(), updated_at = NOW()
           WHERE (actor_uid = $1 AND target_uid = $2)
              OR (actor_uid = $2 AND target_uid = $1)`,
          [uid, targetUid]
        );
        await refreshTrustScore(uid, { source: "daily_match" });
        await refreshTrustScore(targetUid, { source: "daily_match" });
      }
    }

    return { ok: true, isMutual };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.generateDailyQueueScheduled = onSchedule(
  {
    schedule: "30 0 * * *",
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
    secrets: [neonDatabaseUrl],
  },
  async () => {
    const result = await generateDailyQueueForAllUsers();
    logger.info("generate_daily_queue", result);
  }
);

exports.learnWeightMapsScheduled = onSchedule(
  {
    schedule: "30 18 * * *",
    timeZone: "Asia/Kolkata",
    region: "asia-south1",
    secrets: [neonDatabaseUrl],
  },
  async () => {
    const result = await learnWeightMapsForAllUsers();
    logger.info("learn_weight_maps", result);
  }
);

module.exports.generateQueueForUser = generateQueueForUser;
