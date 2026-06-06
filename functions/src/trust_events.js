const { query } = require("./db");
const { computeTrustTier, REPORT_PENALTY, TRUST_SCORE_MAX } = require("./trust");

const TIER_LABELS = {
  trusted: "Trusted",
  highly_trusted: "Highly trusted",
  elite: "Elite",
};

function tierHeadline(tier) {
  const label = TIER_LABELS[tier] || "Trusted";
  return `Your trust score is ${label.toLowerCase()}.`;
}

function clampScore(value) {
  return Math.max(0, Math.min(TRUST_SCORE_MAX, Math.round(value)));
}

function scoreFromParts(profilePts, behaviorPts, reportsCount) {
  return clampScore(profilePts + behaviorPts - reportsCount * REPORT_PENALTY);
}

/**
 * Writes ledger rows when trust buckets, penalties, or tier change.
 */
async function recordTrustScoreEvents(uid, before, after, context = {}) {
  const prevProfile = Number(before?.profile_points ?? 0);
  const prevBehavior = Number(before?.behavior_points ?? 0);
  const prevReports = Number(before?.reports_received ?? 0);
  const prevTier = before?.tier || "trusted";

  const nextProfile = Number(after.profilePoints ?? 0);
  const nextBehavior = Number(after.behaviorPoints ?? 0);
  const nextReports = Number(after.reportsCount ?? prevReports);
  const nextTier = after.trustTier || computeTrustTier(after.trustScore ?? 0);

  const deltaProfile = nextProfile - prevProfile;
  const deltaBehavior = nextBehavior - prevBehavior;
  const deltaReports = nextReports - prevReports;

  const events = [];
  const baseMeta = {
    source: context.source || "recompute",
    ...(context.metadata || {}),
  };

  if (deltaProfile !== 0) {
    const scoreBefore = scoreFromParts(prevProfile, prevBehavior, prevReports);
    const scoreAfter = scoreFromParts(nextProfile, prevBehavior, prevReports);
    events.push({
      event_type: context.profileEventType || "profile_updated",
      category: "profile",
      title:
        deltaProfile > 0 ? "Profile trust increased" : "Profile trust decreased",
      body:
        context.profileBody ||
        (deltaProfile > 0
          ? "Your biodata added trust points."
          : "Profile changes reduced trust points."),
      delta_profile: deltaProfile,
      delta_behavior: 0,
      delta_total: scoreAfter - scoreBefore,
      profile_points_after: nextProfile,
      behavior_points_after: prevBehavior,
      score_before: scoreBefore,
      score_after: scoreAfter,
      tier_after: computeTrustTier(scoreAfter),
      metadata: baseMeta,
    });
  }

  if (deltaBehavior !== 0) {
    const profileAfterProfileStep = nextProfile;
    const scoreBefore = scoreFromParts(
      profileAfterProfileStep,
      prevBehavior,
      prevReports
    );
    const scoreAfter = scoreFromParts(
      profileAfterProfileStep,
      nextBehavior,
      prevReports
    );
    events.push({
      event_type: context.behaviorEventType || "behavior_updated",
      category: "behavior",
      title:
        deltaBehavior > 0
          ? "Behavior trust increased"
          : "Behavior trust decreased",
      body:
        context.behaviorBody ||
        (deltaBehavior > 0
          ? "Activity with members and events boosted your score."
          : "Behavior metrics changed your trust score."),
      delta_profile: 0,
      delta_behavior: deltaBehavior,
      delta_total: scoreAfter - scoreBefore,
      profile_points_after: profileAfterProfileStep,
      behavior_points_after: nextBehavior,
      score_before: scoreBefore,
      score_after: scoreAfter,
      tier_after: computeTrustTier(scoreAfter),
      metadata: baseMeta,
    });
  }

  if (deltaReports !== 0) {
    const scoreBefore = scoreFromParts(nextProfile, nextBehavior, prevReports);
    const scoreAfter = scoreFromParts(nextProfile, nextBehavior, nextReports);
    const penaltyDelta = scoreAfter - scoreBefore;
    events.push({
      event_type: "report_penalty",
      category: "penalty",
      title: "Trust penalty applied",
      body:
        context.penaltyBody ||
        "A validated report affected your trust score.",
      delta_profile: 0,
      delta_behavior: 0,
      delta_total: penaltyDelta,
      profile_points_after: nextProfile,
      behavior_points_after: nextBehavior,
      score_before: scoreBefore,
      score_after: scoreAfter,
      tier_after: computeTrustTier(scoreAfter),
      metadata: { ...baseMeta, reports_received: nextReports },
    });
  }

  if (
    events.length === 0 &&
    prevTier !== nextTier
  ) {
    const score = scoreFromParts(nextProfile, nextBehavior, nextReports);
    events.push({
      event_type: "tier_changed",
      category: "system",
      title: `You're now ${TIER_LABELS[nextTier]}`,
      body: tierHeadline(nextTier),
      delta_profile: 0,
      delta_behavior: 0,
      delta_total: 0,
      profile_points_after: nextProfile,
      behavior_points_after: nextBehavior,
      score_before: score,
      score_after: score,
      tier_after: nextTier,
      metadata: { ...baseMeta, previous_tier: prevTier },
    });
  } else if (prevTier !== nextTier && events.length > 0) {
    const last = events[events.length - 1];
    if (last.tier_after !== nextTier) {
      events.push({
        event_type: "tier_changed",
        category: "system",
        title: `You're now ${TIER_LABELS[nextTier]}`,
        body: tierHeadline(nextTier),
        delta_profile: 0,
        delta_behavior: 0,
        delta_total: 0,
        profile_points_after: nextProfile,
        behavior_points_after: nextBehavior,
        score_before: last.score_after,
        score_after: last.score_after,
        tier_after: nextTier,
        metadata: { ...baseMeta, previous_tier: prevTier },
      });
    }
  }

  for (const event of events) {
    await query(
      `INSERT INTO trust_score_events (
         uid, event_type, category, title, body,
         delta_profile, delta_behavior, delta_total,
         profile_points_after, behavior_points_after,
         score_before, score_after, tier_after, metadata
       ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
      [
        uid,
        event.event_type,
        event.category,
        event.title,
        event.body,
        event.delta_profile,
        event.delta_behavior,
        event.delta_total,
        event.profile_points_after,
        event.behavior_points_after,
        event.score_before,
        event.score_after,
        event.tier_after,
        JSON.stringify(event.metadata),
      ]
    );
  }

  return events;
}

async function seedInitialTrustEvent(uid, after) {
  const existing = await query(
    `SELECT 1 FROM trust_score_events WHERE uid = $1 LIMIT 1`,
    [uid]
  );
  if (existing.rowCount > 0) return;

  const score = Number(after.trustScore ?? 0);
  const tier = after.trustTier || computeTrustTier(score);
  const profilePts = Number(after.profilePoints ?? 0);
  const behaviorPts = Number(after.behaviorPoints ?? 0);

  await query(
    `INSERT INTO trust_score_events (
       uid, event_type, category, title, body,
       delta_profile, delta_behavior, delta_total,
       profile_points_after, behavior_points_after,
       score_before, score_after, tier_after, metadata
     ) VALUES ($1,'initial_score','system',$2,$3,$4,$5,$6,$4,$5,0,$6,$7,$8)`,
    [
      uid,
      "Your trust score is live",
      tierHeadline(tier),
      profilePts,
      behaviorPts,
      score,
      tier,
      JSON.stringify({ source: "backfill" }),
    ]
  );
}

function mapTrustEventRow(row) {
  return {
    id: row.id,
    createdAt: row.created_at,
    eventType: row.event_type,
    category: row.category,
    title: row.title,
    body: row.body,
    deltaProfile: Number(row.delta_profile || 0),
    deltaBehavior: Number(row.delta_behavior || 0),
    deltaTotal: Number(row.delta_total || 0),
    profilePointsAfter:
      row.profile_points_after != null
        ? Number(row.profile_points_after)
        : null,
    behaviorPointsAfter:
      row.behavior_points_after != null
        ? Number(row.behavior_points_after)
        : null,
    scoreBefore: Number(row.score_before || 0),
    scoreAfter: Number(row.score_after || 0),
    tierAfter: row.tier_after,
    metadata: row.metadata || {},
  };
}

async function fetchTrustEvents(uid, { limit = 50, category = null } = {}) {
  const values = [uid, limit];
  let sql = `
    SELECT *
    FROM trust_score_events
    WHERE uid = $1
  `;
  if (category) {
    values.push(category);
    sql += ` AND category = $3`;
  }
  sql += ` ORDER BY created_at DESC LIMIT $2`;

  const result = await query(sql, values);
  return result.rows.map(mapTrustEventRow);
}

module.exports = {
  recordTrustScoreEvents,
  seedInitialTrustEvent,
  fetchTrustEvents,
  mapTrustEventRow,
  tierHeadline,
  TIER_LABELS,
};
