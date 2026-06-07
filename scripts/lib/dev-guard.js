const fs = require("node:fs");
const path = require("node:path");

const ALLOWED_PROJECT_ID = "vetted-dev-ea19c";

function readDefaultProjectId() {
  try {
    const firebasercPath = path.join(__dirname, "../../.firebaserc");
    const raw = fs.readFileSync(firebasercPath, "utf8");
    const parsed = JSON.parse(raw);
    return parsed?.projects?.default || null;
  } catch {
    return null;
  }
}

function resolveProjectId() {
  return (
    process.env.FIREBASE_PROJECT_ID?.trim() ||
    readDefaultProjectId() ||
    ALLOWED_PROJECT_ID
  );
}

function assertDevSeedAllowed({ requireConfirm = true } = {}) {
  const projectId = resolveProjectId();
  if (projectId !== ALLOWED_PROJECT_ID) {
    throw new Error(
      `Refusing to run against Firebase project "${projectId}". Dev project only: ${ALLOWED_PROJECT_ID}.`
    );
  }

  if (requireConfirm && process.env.CONFIRM_DEV_SEED !== "yes") {
    throw new Error(
      "Set CONFIRM_DEV_SEED=yes to confirm you are targeting the dev environment."
    );
  }

  if (!process.env.NEON_DATABASE_URL?.trim()) {
    throw new Error("NEON_DATABASE_URL is required.");
  }

  return projectId;
}

module.exports = {
  ALLOWED_PROJECT_ID,
  resolveProjectId,
  assertDevSeedAllowed,
};
