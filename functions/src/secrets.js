const { defineSecret } = require("firebase-functions/params");

const neonDatabaseUrl = defineSecret("NEON_DATABASE_URL");
const razorpayKeyId = defineSecret("RAZORPAY_KEY_ID");
const razorpayKeySecret = defineSecret("RAZORPAY_KEY_SECRET");
const razorpayPlanId = defineSecret("RAZORPAY_PLAN_ID");

module.exports = {
  neonDatabaseUrl,
  razorpayKeyId,
  razorpayKeySecret,
  razorpayPlanId,
};
