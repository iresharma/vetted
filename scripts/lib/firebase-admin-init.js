const path = require("node:path");
const { resolveProjectId } = require("./dev-guard");

const admin = require(path.join(__dirname, "../../functions/node_modules/firebase-admin"));

function initFirebaseAdmin() {
  const projectId = resolveProjectId();

  if (!admin.apps.length) {
    admin.initializeApp({ projectId });
  }

  return admin;
}

async function verifyFirebaseAdminAccess() {
  const app = initFirebaseAdmin();
  await app.auth().listUsers(1);
  return app;
}

module.exports = {
  initFirebaseAdmin,
  verifyFirebaseAdminAccess,
};
