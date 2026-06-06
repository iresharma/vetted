#!/usr/bin/env node
/**
 * One-off backfill: recompute trust_scores for every profile.
 *
 * Usage:
 *   NEON_DATABASE_URL=... node scripts/backfill-trust-scores.js
 */
const path = require("node:path");
const { Pool } = require(path.join(__dirname, "../functions/node_modules/pg"));
const { computeTrustScore } = require(path.join(__dirname, "../functions/src/trust"));

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

  const { rows: profiles } = await pool.query(
    `SELECT p.*, t.*
     FROM profiles p
     LEFT JOIN trust_scores t ON t.uid = p.uid`
  );

  console.log(`Recomputing trust for ${profiles.length} profile(s)...`);

  for (const row of profiles) {
    const uid = row.uid;
    await pool.query(
      `INSERT INTO trust_scores(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`,
      [uid]
    );

    const reportsCount = await countValidReports(pool, uid);
    const mutualMatchCount = await countMutualMatches(pool, uid);
    const computed = computeTrustScore({
      profileRow: row,
      trustRow: row,
      reportsCount,
      mutualMatchCount,
    });

    await pool.query(
      `UPDATE profiles SET is_live = $2, updated_at = NOW() WHERE uid = $1`,
      [uid, computed.isLive]
    );

    await pool.query(
      `UPDATE trust_scores
       SET score = $2, tier = $3, profile_points = $4, behavior_points = $5,
           reports_received = $6, updated_at = NOW()
       WHERE uid = $1`,
      [
        uid,
        computed.trustScore,
        computed.trustTier,
        computed.profilePoints,
        computed.behaviorPoints,
        reportsCount,
      ]
    );

    console.log(
      `${uid}: score=${computed.trustScore} profile=${computed.profilePoints} behavior=${computed.behaviorPoints} live=${computed.isLive}`
    );
  }

  await pool.end();
  console.log("Done.");
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
