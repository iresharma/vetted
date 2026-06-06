#!/usr/bin/env node
/**
 * Seed initial trust_score_events for users who have scores but no ledger rows.
 *
 * Usage:
 *   NEON_DATABASE_URL=... node scripts/seed-trust-events.js
 */
const path = require("node:path");
const { Pool } = require(path.join(__dirname, "../functions/node_modules/pg"));
const { computeTrustScore } = require(path.join(__dirname, "../functions/src/trust"));
const {
  seedInitialTrustEvent,
} = require(path.join(__dirname, "../functions/src/trust_events"));

async function countValidReports(pool, uid) {
  const { rows } = await pool.query(
    `SELECT COUNT(*)::int AS count FROM reports WHERE reported_uid = $1 AND is_valid = TRUE`,
    [uid]
  );
  return rows[0]?.count || 0;
}

async function countMutualMatches(pool, uid) {
  const { rows } = await pool.query(
    `SELECT COUNT(*)::int AS count FROM interactions
     WHERE (actor_uid = $1 OR target_uid = $1) AND is_mutual = TRUE`,
    [uid]
  );
  return rows[0]?.count || 0;
}

async function main() {
  const connectionString = process.env.NEON_DATABASE_URL;
  if (!connectionString) {
    console.error("NEON_DATABASE_URL is required");
    process.exit(1);
  }

  const pool = new Pool({
    connectionString,
    ssl: { rejectUnauthorized: false },
  });

  const { rows } = await pool.query(
    `SELECT p.*, t.*
     FROM profiles p
     JOIN trust_scores t ON t.uid = p.uid`
  );

  for (const row of rows) {
    const reportsCount = await countValidReports(pool, row.uid);
    const mutualMatchCount = await countMutualMatches(pool, row.uid);
    const computed = computeTrustScore({
      profileRow: row,
      trustRow: row,
      reportsCount,
      mutualMatchCount,
    });
    await seedInitialTrustEvent(row.uid, computed);
    console.log(`Seeded initial event for ${row.uid} (score=${computed.trustScore})`);
  }

  await pool.end();
  console.log("Done.");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
