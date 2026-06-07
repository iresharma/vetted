#!/usr/bin/env node
/**
 * Verify Firebase Admin credentials (service account or ADC).
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node scripts/verify-firebase-admin.js
 */
const { resolveProjectId } = require("./lib/dev-guard");
const { verifyFirebaseAdminAccess } = require("./lib/firebase-admin-init");

async function main() {
  const projectId = resolveProjectId();
  console.log(`Checking Firebase Admin access for project ${projectId}...`);
  await verifyFirebaseAdminAccess();
  console.log("OK — Firebase Admin credentials are valid.");
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});