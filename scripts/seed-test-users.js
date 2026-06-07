#!/usr/bin/env node
/**
 * Creates prod-like partner variation (5 scenario types) so Daily 5 scores
 * and breakdowns match production: weighted overall, per-field differences,
 * and trust bonus spread. Re-seed after this change if you still have old
 * identical-match test users.
 *
 * Prerequisites:
 *   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/vetted-dev-firebase-admin.json
 *   export FIREBASE_PROJECT_ID=vetted-dev-ea19c
 *   export NEON_DATABASE_URL=postgresql://...
 *   export CONFIRM_DEV_SEED=yes
 *
 * Usage:
 *   node scripts/seed-test-users.js --count 10 --viewer-phone 8582871444
 *   node scripts/seed-test-users.js --count 5 --viewer-uid <firebase-uid>
 */
const { assertDevSeedAllowed } = require("./lib/dev-guard");
const { initFirebaseAdmin, verifyFirebaseAdminAccess } = require("./lib/firebase-admin-init");
const { withTransaction, closePool } = require("./lib/pg-pool");
const { parseArgs } = require("./lib/parse-args");
const {
  buildProfilePayload,
  loadViewerContext,
  summarizePartnerPlan,
  resolveWeightMap,
  insertPostgresUser,
  partnerGenderForIndex,
  testPhoneE164,
  testPhoneDisplay,
  readManifest,
  writeManifest,
} = require("./lib/test-user-fixtures");

async function phoneInUse(admin, phone) {
  try {
    await admin.auth().getUserByPhoneNumber(phone);
    return true;
  } catch (error) {
    if (error.code === "auth/user-not-found") return false;
    throw error;
  }
}

async function nextAvailableIndex(admin, startIndex, count) {
  const indices = [];
  let index = startIndex;
  while (indices.length < count) {
    const phone = testPhoneE164(index);
    // eslint-disable-next-line no-await-in-loop
    const used = await phoneInUse(admin, phone);
    if (!used) indices.push(index);
    index += 1;
    if (index > 9999) {
      throw new Error("Ran out of test phone numbers in the +919000000XXX range.");
    }
  }
  return indices;
}

async function main() {
  const args = parseArgs();
  const count = Math.max(1, Number.parseInt(args.count || "10", 10));
  const startIndex = Math.max(1, Number.parseInt(args.start || "1", 10));

  assertDevSeedAllowed();
  await verifyFirebaseAdminAccess();
  const admin = initFirebaseAdmin();

  const viewerContext = await loadViewerContext({
    viewerUid: args["viewer-uid"],
    viewerPhone: args["viewer-phone"],
  });
  const { viewer } = viewerContext;
  const plan = summarizePartnerPlan(viewerContext, count);

  console.log(`Seeding ${count} partner profile(s) for viewer ${viewer.display_name || viewer.uid}`);
  console.log(JSON.stringify(plan, null, 2));

  const indices = await nextAvailableIndex(admin, startIndex, count);
  const manifest = readManifest();
  const created = [];

  for (const index of indices) {
    const phone = testPhoneE164(index);
    const gender = partnerGenderForIndex(viewer, index);
    const payload = buildProfilePayload({
      index,
      gender,
      viewerContext,
      totalCount: count,
    });
    const weightMap = await resolveWeightMap(payload.profile);

    let authUser;
    try {
      authUser = await admin.auth().createUser({
        phoneNumber: phone,
        displayName: payload.displayName,
      });
    } catch (error) {
      console.error(`Failed to create Firebase user for ${phone}: ${error.message}`);
      continue;
    }

    try {
      await withTransaction(async (client) => {
        await insertPostgresUser(client, {
          uid: authUser.uid,
          phone,
          payload,
          weightMap,
        });
      });
    } catch (error) {
      await admin.auth().deleteUser(authUser.uid);
      throw error;
    }

    const entry = {
      uid: authUser.uid,
      phone,
      phoneLocal: testPhoneDisplay(index),
      displayName: payload.displayName,
      gender,
      verifiedAge: payload.verifiedAge,
      diet: payload.profile.diet,
      kidsPreference: payload.profile.kids_preference,
      seededForViewerUid: viewer.uid,
      index,
      scenarioId: payload.scenarioId,
      scenarioSlug: payload.scenarioSlug,
      scenarioLabel: payload.scenarioLabel,
      previewCompatibilityScore: payload.previewCompatibilityScore,
    };
    created.push(entry);
    console.log(
      `Created ${entry.displayName} (${phone}) age=${entry.verifiedAge} ` +
        `scenario=${entry.scenarioSlug} previewScore=${entry.previewCompatibilityScore}% uid=${entry.uid}`
    );
  }

  manifest.createdAt = new Date().toISOString();
  manifest.viewerUid = viewer.uid;
  manifest.partnerPlan = plan;
  manifest.users = [...(manifest.users || []), ...created];
  writeManifest(manifest);

  console.log("\nDone. Register these in Firebase Console → Authentication → Phone → Phone numbers for testing:");
  console.log("Phone (local 10-digit) | OTP");
  for (const user of created) {
    console.log(`${user.phoneLocal} | 123456`);
  }
  console.log("\nNext steps:");
  console.log("  node scripts/cleanup-test-users.js   # if replacing old identical-match test users");
  console.log(`  node scripts/generate-daily-queue.js --viewer-uid ${viewer.uid}`);
  console.log("  (Queue generation uses prod-like matcher scores; re-seed users for varied breakdowns.)");
  console.log(`  node scripts/seed-test-chat.js --viewer-uid ${viewer.uid} --with-messages`);

  await closePool();
}

main().catch(async (error) => {
  console.error(error.message);
  await closePool().catch(() => {});
  process.exit(1);
});
