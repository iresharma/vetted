#!/usr/bin/env node
/**
 * (Optional) Re-seed reverse interest for test users in today's Daily 5 queue.
 * generate-daily-queue.js does this automatically — use this script only if you
 * need to refresh match state without regenerating the queue.
 *
 * Usage:
 *   CONFIRM_DEV_SEED=yes NEON_DATABASE_URL=... \
 *   node scripts/seed-test-matches.js --viewer-uid <uid> --count 3
 */
const { assertDevSeedAllowed } = require("./lib/dev-guard");
const { getPool, closePool } = require("./lib/pg-pool");
const { parseArgs } = require("./lib/parse-args");
const { loadViewer } = require("./lib/test-user-fixtures");
const { seedReverseInterestForQueue } = require("./lib/seed-reverse-interest");

async function main() {
  const args = parseArgs();
  assertDevSeedAllowed();

  const count = Math.max(1, Number.parseInt(args.count || "3", 10));
  const viewer = await loadViewer({
    viewerUid: args["viewer-uid"],
    viewerPhone: args["viewer-phone"],
  });

  const pool = getPool();
  const targets = await seedReverseInterestForQueue(pool, viewer.uid, { count });
  if (targets.length === 0) {
    throw new Error(
      "No test users in today's Daily 5 queue. Run generate-daily-queue.js first."
    );
  }

  for (const target of targets) {
    console.log(
      `Seeded ${target.display_name} → interested in you. Tap Interested in Daily 5 for the match overlay.`
    );
  }

  console.log(`\nSeeded reverse interest for ${targets.length} queue profile(s).`);
  console.log("Hot-restart the app (or re-open Daily 5) so badges refresh.");
  await closePool();
}

main().catch(async (error) => {
  console.error(error.message);
  await closePool().catch(() => {});
  process.exit(1);
});
