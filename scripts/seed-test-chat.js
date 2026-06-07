#!/usr/bin/env node
/**
 * Bootstrap Firestore chat threads between the viewer and test users.
 *
 * Usage:
 *   CONFIRM_DEV_SEED=yes \
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   NEON_DATABASE_URL=... \
 *   node scripts/seed-test-chat.js --viewer-uid <uid> --count 3 --with-messages
 */
const { assertDevSeedAllowed } = require("./lib/dev-guard");
const { initFirebaseAdmin, verifyFirebaseAdminAccess } = require("./lib/firebase-admin-init");
const { closePool } = require("./lib/pg-pool");
const { parseArgs } = require("./lib/parse-args");
const { loadViewer, listTestUsersFromDb } = require("./lib/test-user-fixtures");

function buildThreadId(uidA, uidB) {
  return [uidA, uidB].sort().join("_");
}

async function ensureThread(db, { viewerUid, viewerName, targetUid, targetName }) {
  const threadId = buildThreadId(viewerUid, targetUid);
  const ref = db.collection("chat_threads").doc(threadId);
  const snap = await ref.get();
  const members = [viewerUid, targetUid].sort();

  if (!snap.exists) {
    await ref.set({
      members,
      memberNames: {
        [viewerUid]: viewerName,
        [targetUid]: targetName,
      },
      lastMessage: "",
      lastMessageAt: new Date(),
      unreadCount: {
        [viewerUid]: 0,
        [targetUid]: 0,
      },
    });
  }

  return { threadId, ref, created: !snap.exists };
}

async function seedMessages(ref, { targetUid, targetName, viewerUid }) {
  const samples = [
    "Hey! Nice to match with you on Vetted Club.",
    "Would love to chat more when you have a moment.",
  ];

  let lastText = "";
  for (const text of samples) {
    const messageRef = ref.collection("messages").doc();
    await messageRef.set({
      senderId: targetUid,
      senderName: targetName,
      text,
      createdAt: new Date(),
      readBy: [targetUid],
    });
    lastText = text;
  }

  await ref.update({
    lastMessage: lastText,
    lastMessageAt: new Date(),
    [`unreadCount.${viewerUid}`]: samples.length,
    [`unreadCount.${targetUid}`]: 0,
  });
}

async function main() {
  const args = parseArgs();
  assertDevSeedAllowed();
  await verifyFirebaseAdminAccess();

  const count = Math.max(1, Number.parseInt(args.count || "3", 10));
  const withMessages = Boolean(args["with-messages"]);

  const viewer = await loadViewer({
    viewerUid: args["viewer-uid"],
    viewerPhone: args["viewer-phone"],
  });
  const viewerName = viewer.display_name || "You";

  const testUsers = await listTestUsersFromDb();
  if (testUsers.length === 0) {
    throw new Error("No test users found. Run scripts/seed-test-users.js first.");
  }

  const admin = initFirebaseAdmin();
  const db = admin.firestore();
  const targets = testUsers.slice(0, count);

  for (const target of targets) {
    const { threadId, ref, created } = await ensureThread(db, {
      viewerUid: viewer.uid,
      viewerName,
      targetUid: target.uid,
      targetName: target.display_name || "Test Member",
    });

    if (withMessages) {
      await seedMessages(ref, {
        targetUid: target.uid,
        targetName: target.display_name || "Test Member",
        viewerUid: viewer.uid,
      });
    }

    console.log(
      `${created ? "Created" : "Reused"} thread ${threadId} with ${target.display_name}`
    );
  }

  console.log(`Processed ${targets.length} chat thread(s).`);
  await closePool();
}

main().catch(async (error) => {
  console.error(error.message);
  await closePool().catch(() => {});
  process.exit(1);
});
