#!/usr/bin/env node
/**
 * Remove seeded test users from Firestore, Firebase Auth, and Postgres.
 *
 * Usage:
 *   CONFIRM_DEV_SEED=yes \
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   NEON_DATABASE_URL=... \
 *   node scripts/cleanup-test-users.js
 */
const { assertDevSeedAllowed } = require("./lib/dev-guard");
const { initFirebaseAdmin, verifyFirebaseAdminAccess } = require("./lib/firebase-admin-init");
const { getPool, closePool } = require("./lib/pg-pool");
const {
  readManifest,
  writeManifest,
  listTestUsersFromDb,
} = require("./lib/test-user-fixtures");

async function deleteThread(db, threadId) {
  const threadRef = db.collection("chat_threads").doc(threadId);
  const messagesSnap = await threadRef.collection("messages").get();
  const batch = db.batch();
  for (const doc of messagesSnap.docs) {
    batch.delete(doc.ref);
  }
  batch.delete(threadRef);
  await batch.commit();
}

async function deleteThreadsForUser(db, uid) {
  const snap = await db.collection("chat_threads").where("members", "array-contains", uid).get();
  for (const doc of snap.docs) {
    await deleteThread(db, doc.id);
  }
  return snap.size;
}

async function main() {
  assertDevSeedAllowed();
  await verifyFirebaseAdminAccess();

  const admin = initFirebaseAdmin();
  const db = admin.firestore();
  const pool = getPool();

  const manifestUsers = readManifest().users || [];
  const dbUsers = await listTestUsersFromDb();
  const byUid = new Map();
  for (const user of [...manifestUsers, ...dbUsers]) {
    byUid.set(user.uid, user);
  }

  const users = [...byUid.values()];
  if (users.length === 0) {
    console.log("No test users to clean up.");
    await closePool();
    return;
  }

  let threadsDeleted = 0;
  let authDeleted = 0;
  let postgresDeleted = 0;

  for (const user of users) {
    threadsDeleted += await deleteThreadsForUser(db, user.uid);

    try {
      await admin.auth().deleteUser(user.uid);
      authDeleted += 1;
    } catch (error) {
      if (error.code !== "auth/user-not-found") {
        console.warn(`Auth delete failed for ${user.uid}: ${error.message}`);
      }
    }

    const result = await pool.query(`DELETE FROM users WHERE uid = $1`, [user.uid]);
    if (result.rowCount > 0) postgresDeleted += 1;
    console.log(`Removed ${user.display_name || user.uid}`);
  }

  writeManifest({ createdAt: null, viewerUid: null, users: [] });

  console.log(
    `\nCleanup complete. threads=${threadsDeleted} auth=${authDeleted} postgres=${postgresDeleted}`
  );
  await closePool();
}

main().catch(async (error) => {
  console.error(error.message);
  await closePool().catch(() => {});
  process.exit(1);
});
