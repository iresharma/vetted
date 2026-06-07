const path = require("node:path");
const { Pool } = require(path.join(__dirname, "../../functions/node_modules/pg"));

let pool;

function getPool() {
  const connectionString = process.env.NEON_DATABASE_URL?.trim();
  if (!connectionString) {
    throw new Error("NEON_DATABASE_URL is required.");
  }

  if (!pool) {
    pool = new Pool({
      connectionString,
      ssl: { rejectUnauthorized: false },
    });
  }

  return pool;
}

async function withTransaction(work) {
  const client = await getPool().connect();
  try {
    await client.query("BEGIN");
    const result = await work(client);
    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

async function closePool() {
  if (pool) {
    await pool.end();
    pool = null;
  }
}

module.exports = {
  getPool,
  withTransaction,
  closePool,
};
