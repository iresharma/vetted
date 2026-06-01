const { HttpsError } = require("firebase-functions/v2/https");

function requireUid(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  return uid;
}

function requireAdmin(request) {
  requireUid(request);
  const isAdmin = request.auth.token && request.auth.token.admin === true;
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Admin access required.");
  }
}

module.exports = {
  requireUid,
  requireAdmin,
};
