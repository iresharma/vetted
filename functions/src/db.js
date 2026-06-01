const { logger } = require("firebase-functions");
const { Pool } = require("pg");

let pool;

function getConnectionString() {
  const value = process.env.NEON_DATABASE_URL;
  if (!value) {
    throw new Error("NEON_DATABASE_URL secret is not configured");
  }
  return value;
}

function getPool() {
  if (pool) return pool;

  pool = new Pool({
    connectionString: getConnectionString(),
    max: 5,
    ssl: { rejectUnauthorized: false },
  });

  pool.on("error", (error) => {
    logger.error("postgres_pool_error", { message: error.message });
  });

  return pool;
}

async function query(text, values = []) {
  return getPool().query(text, values);
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

module.exports = {
  query,
  withTransaction,
};
