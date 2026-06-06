const crypto = require("node:crypto");
const { logger } = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { query, withTransaction } = require("./db");
const { requireUid } = require("./auth");
const {
  profileAllowedKeys,
  preferenceAllowedKeys,
  profileTextArrayColumns,
  preferenceTextArrayColumns,
  profileBoolColumns,
  profileIntColumns,
  profileTimeColumns,
  parseTextArray,
  coerceTextArray,
  mergeProfileExtras,
  normalizePayload,
  buildDynamicUpdate,
} = require("./profile");
const { computeTrustScore, computeProfileBreakdown, computeBehaviorBreakdown } = require("./trust");
const {
  recordTrustScoreEvents,
  fetchTrustEvents,
  tierHeadline,
} = require("./trust_events");
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

async function countValidReports(uid) {
  const result = await query(
    `SELECT COUNT(*)::int AS count
     FROM reports
     WHERE reported_uid = $1 AND is_valid = TRUE`,
    [uid]
  );
  return result.rows[0]?.count || 0;
}

async function countMutualMatches(uid) {
  const result = await query(
    `SELECT COUNT(*)::int AS count
     FROM interactions
     WHERE (actor_uid = $1 OR target_uid = $1)
       AND is_mutual = TRUE`,
    [uid]
  );
  return result.rows[0]?.count || 0;
}

async function ensureTrustScoreRow(uid, client = null) {
  const run = client ? client.query.bind(client) : query;
  await run(
    `INSERT INTO trust_scores(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`,
    [uid]
  );
}

async function refreshTrustScore(uid, context = {}) {
  const readback = await query(
    `SELECT p.*, t.*
     FROM profiles p
     LEFT JOIN trust_scores t ON t.uid = p.uid
     WHERE p.uid = $1`,
    [uid]
  );
  if (readback.rowCount === 0) {
    return {
      trustScore: 0,
      trustTier: "trusted",
      profilePoints: 0,
      behaviorPoints: 0,
      reportsCount: 0,
      isLive: false,
    };
  }

  await ensureTrustScoreRow(uid);

  const row = readback.rows[0];
  const before = {
    score: Number(row.score ?? 0),
    profile_points: Number(row.profile_points ?? 0),
    behavior_points: Number(row.behavior_points ?? 0),
    tier: row.tier || "trusted",
    reports_received: Number(row.reports_received ?? 0),
  };

  const reportsCount = await countValidReports(uid);
  const mutualMatchCount = await countMutualMatches(uid);
  const computed = computeTrustScore({
    profileRow: row,
    trustRow: row,
    reportsCount,
    mutualMatchCount,
  });

  const after = { ...computed, reportsCount };

  await recordTrustScoreEvents(uid, before, after, context);

  await query(
    `UPDATE profiles
     SET is_live = $2, updated_at = NOW()
     WHERE uid = $1`,
    [uid, computed.isLive]
  );

  await query(
    `UPDATE trust_scores
     SET score = $2,
         tier = $3,
         profile_points = $4,
         behavior_points = $5,
         reports_received = $6,
         updated_at = NOW()
     WHERE uid = $1`,
    [
      uid,
      computed.trustScore,
      computed.trustTier,
      computed.profilePoints,
      computed.behaviorPoints,
      reportsCount,
    ]
  );

  return after;
}

function profileUpdateOptions(payload) {
  return {
    table: "profiles",
    keyColumn: "uid",
    payload,
    touchUpdatedAt: true,
    textArrayColumns: profileTextArrayColumns,
    jsonbColumns: new Set(["profile_extras"]),
    timeColumns: profileTimeColumns,
    intColumns: profileIntColumns,
    boolColumns: profileBoolColumns,
  };
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
      await ensureTrustScoreRow(uid, client);
    });
    return { ok: true, uid };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.saveProfileStep = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const raw = request.data || {};
  const payload = normalizePayload(raw, profileAllowedKeys);

  for (const arrayKey of profileTextArrayColumns) {
    if (Object.prototype.hasOwnProperty.call(payload, arrayKey)) {
      payload[arrayKey] = coerceTextArray(payload[arrayKey], arrayKey);
    }
  }

  try {
    await query(`INSERT INTO profiles(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`, [
      uid,
    ]);

    if (Object.prototype.hasOwnProperty.call(payload, "profile_extras")) {
      const existing = await query(
        `SELECT profile_extras FROM profiles WHERE uid = $1`,
        [uid]
      );
      const currentExtras = existing.rows[0]?.profile_extras || {};
      payload.profile_extras = mergeProfileExtras(
        currentExtras,
        payload.profile_extras
      );
    }

    const { sql, values } = buildDynamicUpdate({
      ...profileUpdateOptions(payload),
      keyValue: uid,
    });
    const result = await query(sql, values);
    if (result.rowCount === 0) {
      throw new HttpsError("not-found", "Profile row not found for user.");
    }

    const readback = await query(
      `SELECT * FROM profiles WHERE uid = $1`,
      [uid]
    );
    const row = readback.rows[0];
    const trust = await refreshTrustScore(uid, {
      source: "save_profile_step",
      profileBody: "Biodata saved — profile trust recalculated.",
    });

    const photoUrls = parseTextArray(row.photo_urls);

    logger.info("save_profile_step", {
      uid,
      keys: Object.keys(payload),
      photoCount: photoUrls.length,
      trustScore: trust.trustScore,
      profilePoints: trust.profilePoints,
      isLive: trust.isLive,
    });

    return {
      ok: true,
      photoUrls,
      trustScore: trust.trustScore,
      trustTier: trust.trustTier,
      profilePoints: trust.profilePoints,
      behaviorPoints: trust.behaviorPoints,
      isLive: trust.isLive,
    };
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
    textArrayColumns: preferenceTextArrayColumns,
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
         p.*
       FROM users u
       LEFT JOIN profiles p ON p.uid = u.uid
       WHERE u.uid = $1`,
      [uid]
    );
    if (result.rowCount === 0) {
      throw new HttpsError("not-found", "User not found.");
    }
    const row = result.rows[0];
    const extras =
      row.profile_extras && typeof row.profile_extras === "object"
        ? row.profile_extras
        : {};

    const trust = await refreshTrustScore(uid);

    return {
      verifiedName: row.verified_name,
      verifiedAge: row.verified_age,
      trustScore: trust.trustScore,
      trustTier: trust.trustTier,
      profilePoints: trust.profilePoints,
      behaviorPoints: trust.behaviorPoints,
      isLive: trust.isLive,
      displayName: row.display_name,
      gender: row.gender,
      city: row.city,
      homeState: row.home_state,
      heightCm: row.height_cm,
      bodyType: row.body_type,
      maritalStatus: row.marital_status,
      hasChildren: row.has_children,
      profession: row.profession,
      fieldOfWork: row.field_of_work,
      employmentType: row.employment_type,
      company: row.company,
      educationLevel: row.education_level,
      college: row.college,
      incomeBracket: row.income_bracket,
      workMode: row.work_mode,
      faith: row.faith,
      religiosity: row.religiosity,
      community: row.community,
      subCaste: row.sub_caste,
      motherTongue: row.mother_tongue,
      languagesSpoken: parseTextArray(row.languages_spoken),
      manglikStatus: row.manglik_status,
      rashi: row.rashi,
      nakshatra: row.nakshatra,
      gotra: row.gotra,
      birthTime: row.birth_time != null ? String(row.birth_time) : null,
      birthPlace: row.birth_place,
      livingArrangementPostMarriage: row.living_arrangement_post_marriage,
      fatherOccupation: row.father_occupation,
      motherOccupation: row.mother_occupation,
      siblings: row.siblings,
      familyLocation: row.family_location,
      grewUpAbroad: row.grew_up_abroad,
      familyStructure: row.family_structure,
      horoscopeMatters: row.horoscope_matters,
      diet: row.diet,
      drinking: row.drinking,
      smoking: row.smoking,
      marriageTimeline: row.marriage_timeline,
      familyInvolvement: row.family_involvement,
      kidsPreference: row.kids_preference,
      willingToRelocate: row.willing_to_relocate,
      openToInterFaith: row.open_to_inter_faith,
      openToInterCommunity: row.open_to_inter_community,
      prompt1Q: row.prompt_1_q,
      prompt1A: row.prompt_1_a,
      prompt2Q: row.prompt_2_q,
      prompt2A: row.prompt_2_a,
      prompt3Q: row.prompt_3_q,
      prompt3A: row.prompt_3_a,
      photoUrls: parseTextArray(row.photo_urls),
      voiceNoteUrl: row.voice_note_url,
      interests: parseTextArray(row.interests),
      profileExtras: extras,
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

    let trustScore = 0;
    let trustTier = "trusted";
    let profilePoints = 0;
    let behaviorPoints = 0;
    let isProfileComplete = Boolean(row.is_profile_live);

    if (row.uid) {
      const refreshed = await refreshTrustScore(uid);
      trustScore = refreshed.trustScore;
      trustTier = refreshed.trustTier;
      profilePoints = refreshed.profilePoints;
      behaviorPoints = refreshed.behaviorPoints;
      isProfileComplete = refreshed.isLive;
    }

    return {
      exists: true,
      uid: row.uid,
      hasPaidEntryPass: Boolean(row.has_paid_entry_pass),
      isIdentityVerified: Boolean(row.is_identity_verified),
      hasActiveSubscription: Boolean(row.has_active_subscription),
      accountStatus: row.account_status,
      trustScore,
      trustTier,
      profilePoints,
      behaviorPoints,
      isProfileComplete,
      isRegistrationComplete,
    };
  } catch (error) {
    throw mapDbError(error);
  }
});

exports.enterClub = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  try {
    await query(`INSERT INTO profiles(uid) VALUES ($1) ON CONFLICT(uid) DO NOTHING`, [
      uid,
    ]);

    const readback = await query(`SELECT * FROM profiles WHERE uid = $1`, [uid]);
    if (readback.rowCount === 0) {
      throw new HttpsError("not-found", "Profile not found for user.");
    }

    const trust = await refreshTrustScore(uid);

    if (!trust.isLive) {
      throw new HttpsError(
        "failed-precondition",
        "Complete all required profile fields before entering the club."
      );
    }

    await query(
      `UPDATE profiles SET is_live = TRUE, updated_at = NOW() WHERE uid = $1`,
      [uid]
    );

    return {
      ok: true,
      isProfileComplete: true,
      trustScore: trust.trustScore,
      trustTier: trust.trustTier,
      profilePoints: trust.profilePoints,
      behaviorPoints: trust.behaviorPoints,
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});

exports.getTrustReport = onCall(callableDefaults, async (request) => {
  const uid = requireUid(request);
  const data = request.data || {};
  const limit = Math.min(Number(data.limit) || 50, 100);
  const category =
    typeof data.category === "string" && data.category.length > 0
      ? data.category
      : null;

  try {
    await ensureTrustScoreRow(uid);

    const profileResult = await query(`SELECT * FROM profiles WHERE uid = $1`, [uid]);
    const profileRow = profileResult.rows[0] || {};
    const reportsCount = await countValidReports(uid);
    const mutualMatchCount = await countMutualMatches(uid);

    let trust;
    const existing = await query(`SELECT * FROM trust_scores WHERE uid = $1`, [uid]);
    if (existing.rowCount === 0) {
      trust = await refreshTrustScore(uid, { source: "get_trust_report" });
    } else {
      const t = existing.rows[0];
      trust = computeTrustScore({
        profileRow,
        trustRow: t,
        reportsCount,
        mutualMatchCount,
      });
    }

    const meta = await query(
      `SELECT updated_at FROM trust_scores WHERE uid = $1`,
      [uid]
    );
    const updatedAt = meta.rows[0]?.updated_at || new Date().toISOString();
    const events = await fetchTrustEvents(uid, { limit, category });
    const profileBreakdown = computeProfileBreakdown(profileRow);
    const behaviorBreakdown = computeBehaviorBreakdown(
      existing.rows[0] || {},
      mutualMatchCount
    );

    return {
      trustScore: trust.trustScore,
      trustTier: trust.trustTier,
      profilePoints: trust.profilePoints,
      behaviorPoints: trust.behaviorPoints,
      profilePointsMax: 150,
      behaviorPointsMax: 50,
      trustScoreMax: 200,
      updatedAt,
      headline: tierHeadline(trust.trustTier),
      profileBreakdown,
      behaviorBreakdown,
      events,
    };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw mapDbError(error);
  }
});
