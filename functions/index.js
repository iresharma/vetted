const admin = require("firebase-admin");
const registration = require("./src/registration");

admin.initializeApp();

exports.upsertUserFromAuth = registration.upsertUserFromAuth;
exports.saveProfileStep = registration.saveProfileStep;
exports.savePreferencesStep = registration.savePreferencesStep;
exports.markIdentityVerified = registration.markIdentityVerified;
exports.getRegistrationStatus = registration.getRegistrationStatus;
exports.getProfileDraft = registration.getProfileDraft;
exports.enterClub = registration.enterClub;
exports.getTrustReport = registration.getTrustReport;
exports.createEntryPassCheckout = registration.createEntryPassCheckout;
exports.confirmEntryPassPayment = registration.confirmEntryPassPayment;
