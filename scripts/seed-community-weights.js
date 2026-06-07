#!/usr/bin/env node
/**
 * Seeds community_weight_defaults from functions/data/community_weight_defaults.json
 * Usage: NEON_DATABASE_URL=... node scripts/seed-community-weights.js
 */
const fs = require("node:fs");
const path = require("node:path");
const { Pool } = require("pg");

async function main() {
  const dbUrl = process.env.NEON_DATABASE_URL;
  if (!dbUrl) {
    console.error("NEON_DATABASE_URL is required");
    process.exit(1);
  }

  const jsonPath = path.join(
    __dirname,
    "../functions/data/community_weight_defaults.json"
  );
  const data = JSON.parse(fs.readFileSync(jsonPath, "utf8"));
  const pool = new Pool({
    connectionString: dbUrl,
    ssl: { rejectUnauthorized: false },
  });

  let upserted = 0;
  for (const row of data.defaults) {
    await pool.query(
      `INSERT INTO community_weight_defaults(faith, mother_tongue, weight_map)
       VALUES ($1::faith_type, $2, $3::jsonb)
       ON CONFLICT (faith, mother_tongue)
       DO UPDATE SET weight_map = EXCLUDED.weight_map`,
      [row.faith, row.mother_tongue, JSON.stringify(row.weight_map)]
    );
    upserted += 1;
  }

  console.log(`Upserted ${upserted} community weight defaults`);
  await pool.end();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
