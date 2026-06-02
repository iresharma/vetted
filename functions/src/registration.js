const crypto = require("node:crypto");
const { logger } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { query, withTransaction } = require("./db");
const { requireUid } = require("./auth");
const {
  profileAllowedKeys,
  preferenceAllowedKeys,
  normalizePayload,
  buildDynamicUpdate,
} = require("./profile");
const {
  neonDatabaseUrl,
  razorpayKeyId,
  razorpayKeySecret,
  razorpayPlanId,
} = require("./secrets");

const callableDefaults = {
  region: "asia-south1",
  enforceAppCheck: true,
  cors: true,
  secrets: [neonDatabaseUrl],
};

function mapDbError(error) {
  if (error && error.code === "23505") {
    return new HttpsError("already-exists", "Duplicate value violates unique constraint.");
  }
  if (error && error.code === "22P02") {
    return new HttpsError("invalid-argument", "Invalid input value.");
  }
  logger.error("db_error", { message: error.message, code: error.code });
  return new HttpsError("internal", "Database operation failed.");
}

exports.upsertUserFromAuth = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const token = request.auth.token || {};
  const phone = (token.phone_number || "").trim();
  const email = token.email ? String(token.email).trim() : null;

  if (!phone) {
    throw new HttpsError("failed-precondition", "Phone number missing on auth token.");
  }

  try {
    await withTransaction(async (client) => {
      await client.query(
        `INSERT INTO users(uid, phone, email, last_active_at)
         VALUES ($1, $2, $3, NOW())
         ON CONFLICT(uid) DO UPDATE
         SET phone = EXCLUDED.phone,
             email = EXCLUDED.email,
             last_active_at = NOW()`,
        [uid, phone, email]
      );
      await client.query(`INSERT INTO profiles(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`, [uid]);
      await client.query(`INSERT INTO preferences(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`, [uid]);
    });
    return { ok: true, uid };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.saveProfileStep = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const payload = normalizePayload(request.data || {}, profileAllowedKeys);
  const { sql, values } = buildDynamicUpdate({
    table: "profiles",
    keyColumn: "uid",
    keyValue: uid,
    payload,
    touchUpdatedAt: true,
  });
  try {
    const result = await query(sql, values);
    if (result.rowCount === 0) {
      throw new HttpsError("not-found", "Profile row not found for user.");
    }
    return { ok: true };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.savePreferencesStep = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const payload = normalizePayload(request.data || {}, preferenceAllowedKeys);
  const { sql, values } = buildDynamicUpdate({
    table: "preferences",
    keyColumn: "uid",
    keyValue: uid,
    payload,
    touchUpdatedAt: true,
  });
  try {
    const result = await query(sql, values);
    if (result.rowCount === 0) {
      throw new HttpsError("not-found", "Preferences row not found for user.");
    }
    return { ok: true };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.markIdentityVerified = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const verifiedName = typeof data.verified_name === "string" ? data.verified_name.trim() : null;
  const verifiedDob = typeof data.verified_dob === "string" ? data.verified_dob : null;
  const verifiedAge = Number.isInteger(data.verified_age) ? data.verified_age : null;

  if (!verifiedName || !verifiedDob || !verifiedAge) {
    throw new HttpsError("invalid-argument", "verified_name, verified_dob, verified_age are required.");
  }

  try {
    await query(
      `UPDATE users
       SET verified_name = $1,
           verified_dob = $2::date,
           verified_age = $3,
           is_identity_verified = TRUE,
           identity_verified_at = NOW(),
           account_status = CASE WHEN has_paid_entry_pass THEN 'active' ELSE account_status END
       WHERE uid = $4`,
      [verifiedName, verifiedDob, verifiedAge, uid]
    );
    return { ok: true };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.createEntryPassCheckout = onCall(
  {
    ...callableDefaults,
    secrets: [neonDatabaseUrl, razorpayKeyId, razorpayKeySecret, razorpayPlanId],
  },
  async (request) => {
    const uid = requireUid(request);
    const customerId = typeof request.data?.customerId === "string" ? request.data.customerId.trim() : uid;
    const planId = process.env.RAZORPAY_PLAN_ID;
    const keyId = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!planId || !keyId || !keySecret) {
      throw new HttpsError("failed-precondition", "Razorpay secrets are not configured.");
    }

    const auth = Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const response = await fetch("https://api.razorpay.com/v1/subscriptions", {
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        plan_id: planId,
        total_count: 120,
        quantity: 1,
        customer_notify: 1,
        notes: { custId: customerId, uid },
      }),
    });

    if (!response.ok) {
      const body = await response.text();
      logger.error("razorpay_create_subscription_failed", { status: response.status, body });
      throw new HttpsError("internal", "Failed to create Razorpay subscription.");
    }

    const payload = await response.json();
    return {
      keyId,
      planId,
      subscriptionId: payload.id,
    };
  }
);

exports.confirmEntryPassPayment = onCall(
  {
    ...callableDefaults,
    secrets: [neonDatabaseUrl, razorpayKeySecret],
  },
  async (request) => {
    const uid = requireUid(request);
    const data = request.data || {};
    const paymentId = String(data.paymentId || "").trim();
    const signature = String(data.signature || "").trim();
    const subscriptionId = String(data.subscriptionId || "").trim();
    const keySecret = process.env.RAZORPAY_KEY_SECRET;

    if (!paymentId || !signature || !subscriptionId) {
      throw new HttpsError("invalid-argument", "paymentId, signature, and subscriptionId are required.");
    }
    if (!keySecret) {
      throw new HttpsError("failed-precondition", "Razorpay secret is not configured.");
    }

    const digest = crypto
      .createHmac("sha256", keySecret)
      .update(`${paymentId}|${subscriptionId}`)
      .digest("hex");
    if (digest !== signature) {
      throw new HttpsError("permission-denied", "Invalid payment signature.");
    }

    try {
      await withTransaction(async (client) => {
        await client.query(
          `UPDATE users
           SET has_paid_entry_pass = TRUE,
               entry_pass_paid_at = NOW(),
               razorpay_entry_payment_id = $1,
               razorpay_entry_order_id = $2,
               account_status = CASE WHEN is_identity_verified THEN 'active' ELSE account_status END
           WHERE uid = $3`,
          [paymentId, subscriptionId, uid]
        );
        await client.query(
          `INSERT INTO subscriptions(
             uid, plan, status, started_at, current_period_start, current_period_end, razorpay_sub_id, amount_paise
           )
           VALUES(
             $1, 'monthly', 'active', NOW(), NOW(), NOW() + INTERVAL '1 month', $2, 19900
           )
           ON CONFLICT (razorpay_sub_id) DO NOTHING`,
          [uid, subscriptionId]
        );
      });
      return { ok: true };
    } catch (error) {
      throw mapDbError(error);
    }
  }
);

exports.getProfileDraft = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    const result = await query(
      `SELECT
         u.verified_name,
         u.verified_age,
         p.photo_urls
       FROM users u
       LEFT JOIN profiles p ON p.uid = u.uid
       WHERE u.uid = $1`,
      [uid]
    );
    if (result.rowCount === 0) {
      throw new HttpsError("not-found", "User not found.");
    }
    const row = result.rows[0];
    return {
      verifiedName: row.verified_name,
      verifiedAge: row.verified_age,
      photoUrls: Array.isArray(row.photo_urls) ? row.photo_urls : [],
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.getRegistrationStatus = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    const statusResult = await query(
      `SELECT
         u.uid,
         u.has_paid_entry_pass,
         u.is_identity_verified,
         u.account_status,
         p.completeness_pct,
         COALESCE(p.is_live, FALSE) AS is_profile_live,
         EXISTS (
           SELECT 1
           FROM subscriptions s
           WHERE s.uid = u.uid
             AND s.status = 'active'
             AND s.current_period_end > NOW()
         ) AS has_active_subscription
       FROM users u
       LEFT JOIN profiles p ON p.uid = u.uid
       WHERE u.uid = $1`,
      [uid]
    );
    if (statusResult.rowCount === 0) {
      return {
        exists: false,
        isRegistrationComplete: false,
        isProfileComplete: false,
      };
    }
    const row = statusResult.rows[0];
    const isRegistrationComplete = Boolean(row.has_paid_entry_pass) && Boolean(row.is_identity_verified);
    return {
      exists: true,
      uid: row.uid,
      hasPaidEntryPass: Boolean(row.has_paid_entry_pass),
      isIdentityVerified: Boolean(row.is_identity_verified),
      hasActiveSubscription: Boolean(row.has_active_subscription),
      accountStatus: row.account_status,
      completenessPct: Number(row.completeness_pct || 0),
      isProfileComplete: Boolean(row.is_profile_live),
      isRegistrationComplete,
    };
  } catch (error) {
    throw mapDbError(error);
  }
});
