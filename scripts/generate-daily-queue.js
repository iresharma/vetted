#!/usr/bin/env node
/**
 * Generate today's Daily 5 queue for a viewer without waiting for the cron job.
 *
 * Uses the same scoring path as production (weighted fields, trust bonus,
 * recency penalty). Test users seeded via seed-test-users.js are built with
 * prod-like profile variation so scores and breakdowns differ naturally.
 *
 * Usage:
 *   CONFIRM_DEV_SEED=yes NEON_DATABASE_URL=... \
 *   node scripts/generate-daily-queue.js --viewer-uid <firebase-uid>
 *
 *   node scripts/generate-daily-queue.js --viewer-uid <uid> --no-reverse-interest
 *   node scripts/generate-daily-queue.js --viewer-uid <uid> --match-count 5
 *
 * Optional legacy UI spread (not prod-like):
 *   node scripts/generate-daily-queue.js --viewer-uid <uid> --spread-scores
 *   node scripts/generate-daily-queue.js --viewer-uid <uid> --spread-scores --scores 100,88,82,76,68
 */
const { assertDevSeedAllowed } = require("./lib/dev-guard");
const { getPool, closePool } = require("./lib/pg-pool");
const { parseArgs } = require("./lib/parse-args");
const { loadViewer } = require("./lib/test-user-fixtures");
const {
  DEFAULT_DEV_SCORES,
  parseTargetScores,
  applyDevScoreSpread,
} = require("./lib/dev-queue-scores");

async function main() {
  const args = parseArgs();
  assertDevSeedAllowed();

  const useSpread = Boolean(args["spread-scores"] || args.scores);
  if (args["real-scores"]) {
    console.log("Note: --real-scores is now the default. Omit --spread-scores for prod-like scoring.");
  }
  const targetScores = useSpread
    ? parseTargetScores(args.scores || DEFAULT_DEV_SCORES.join(","))
    : null;

  const viewer = await loadViewer({
    viewerUid: args["viewer-uid"],
    viewerPhone: args["viewer-phone"],
  });

  const pool = getPool();
  const weightResult = await pool.query(
    `SELECT uid, weight_map, quiz_answers, status
     FROM user_weight_maps
     WHERE uid = $1`,
    [viewer.uid]
  );
  const weightRow = weightResult.rows[0];
  if (!weightRow || !["completed", "skipped"].includes(weightRow.status)) {
    throw new Error(
      `Viewer ${viewer.uid} must complete or skip the values quiz before generating a queue.`
    );
  }

  const { generateQueueForUser, fetchCandidatePool } = require("../functions/src/matching/generate_queue");
  const rows = await generateQueueForUser(viewer.uid, weightRow);

  if (rows.length === 0) {
    const { candidates } = await fetchCandidatePool(viewer.uid);
    if (candidates.length === 0) {
      console.log("No candidates in SQL pool. Re-run seed-test-users.js for this viewer.");
    } else {
      console.log(
        `${candidates.length} candidate(s) in SQL pool but all were excluded by your values-quiz hard filters. Re-run seed-test-users.js — it now mirrors your dealbreakers.`
      );
    }
    await closePool();
    return;
  }

  let output = rows.map((row) => ({
    position: row.position,
    profileUid: row.profile_uid,
    score: row.compatibility_score,
  }));

  if (targetScores) {
    const spread = await applyDevScoreSpread(pool, viewer.uid, targetScores);
    output = spread.map((row, index) => ({
      position: row.position,
      profileUid: rows[index]?.profile_uid,
      score: row.score,
    }));
    console.log(`Applied legacy score spread: ${targetScores.join(", ")}`);
    console.log("Warning: --spread-scores overrides prod-like compatibility scores.");
  }

  console.log(`Generated ${output.length} queue entries for ${viewer.uid} (prod-like scoring):`);
  for (const row of output) {
    console.log(`  #${row.position} profile_uid=${row.profileUid} score=${row.score}%`);
  }

  const skipReverse = Boolean(args["no-reverse-interest"]);
  const matchCount = Math.max(
    0,
    Number.parseInt(args["match-count"] || "3", 10)
  );
  if (!skipReverse && matchCount > 0) {
    const { seedReverseInterestForQueue } = require("./lib/seed-reverse-interest");
    const seeded = await seedReverseInterestForQueue(pool, viewer.uid, {
      count: matchCount,
    });
    if (seeded.length > 0) {
      console.log(
        `\nAuto-seeded reverse interest for ${seeded.length} test profile(s) (mutual match on tap):`
      );
      for (const target of seeded) {
        console.log(`  ${target.display_name} → already interested in you`);
      }
      console.log("Hot-restart the app so Daily 5 picks up reverseInterested badges.");
    } else {
      console.log(
        "\nNo test users in queue — reverse interest not seeded. Re-run seed-test-users.js if needed."
      );
    }
  }

  await closePool();
}

main().catch(async (error) => {
  console.error(error.message);
  await closePool().catch(() => {});
  process.exit(1);
});
