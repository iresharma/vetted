const assert = require("node:assert/strict");
const {
  computeProfileTrust,
  computeBehaviorTrust,
  computeTrustScore,
  computeIsLive,
  REQUIRED_FOR_LIVE,
} = require("../src/trust");

function filledProfile(overrides = {}) {
  const base = {
    display_name: "Test",
    gender: "man",
    city: "Bengaluru",
    marital_status: "never_married",
    prompt_1_a: "a",
    prompt_2_a: "b",
    prompt_3_a: "c",
    photo_urls: ["a", "b", "c"],
    education_level: "Bachelor's",
    field_of_work: "Tech",
    profession: "Engineer",
    faith: "hindu",
    mother_tongue: "Hindi",
    family_structure: "nuclear",
    family_involvement: "i_decide_they_know",
    diet: "vegetarian",
    drinking: "never",
    smoking: "never",
    marriage_timeline: "1_to_2_years",
    kids_preference: "want_kids",
    willing_to_relocate: false,
    profile_extras: {},
  };
  return { ...base, ...overrides };
}

// Live gate: all 21 required fields
assert.equal(computeIsLive(filledProfile()), true);
assert.equal(computeIsLive(filledProfile({ field_of_work: null })), false);
assert.equal(
  computeIsLive(filledProfile({ profile_extras: {} })),
  true,
  "partner_search_approach not required for live"
);

// Profile trust proportional required
const partial = filledProfile({ field_of_work: null, profession: null });
const partialTrust = computeProfileTrust(partial);
assert.equal(partialTrust.isLive, false);
assert.ok(partialTrust.profilePoints < 100);
assert.ok(partialTrust.profilePoints > 0);

// Full profile trust caps at 150 when all optional/extras filled
const fullExtras = {
  partner_search_approach: "Date first",
  weekend_vibe: "Home",
  sleep_schedule: "Early",
  travel_frequency: "Often",
  exercise_frequency: "Daily",
  pet_preference: "Love dogs",
  social_media_presence: "Low",
  mbti: "INTJ",
  love_language: "Words",
  spouse_working_preference: "Yes",
  disability: "No",
};
const fullOptional = {
  home_state: "KA",
  height_cm: 175,
  body_type: "average",
  has_children: "no",
  college: "IIT",
  company: "Co",
  employment_type: "full_time",
  work_mode: "hybrid",
  income_bracket: "20_30",
  religiosity: "moderate",
  community: "General",
  sub_caste: "NA",
  languages_spoken: ["English"],
  horoscope_matters: true,
  manglik_status: "no",
  rashi: "Aries",
  nakshatra: "Ashwini",
  gotra: "Bharadwaj",
  birth_time: "10:00:00",
  birth_place: "Delhi",
  living_arrangement_post_marriage: "Own place",
  father_occupation: "Retired",
  mother_occupation: "Homemaker",
  siblings: "1",
  family_location: "Delhi",
  open_to_inter_faith: true,
  open_to_inter_community: true,
  interests: ["music"],
};
const maxProfile = computeProfileTrust(
  filledProfile({ ...fullOptional, profile_extras: fullExtras })
);
assert.equal(maxProfile.profilePoints, 150);

// Behavior trust max 50
const behavior = computeBehaviorTrust({
  events_attended: 10,
  response_rate_pct: 100,
  positive_feedback_count: 10,
  mutual_match_count: 10,
});
assert.equal(behavior.behaviorPoints, 50);

// Total score clamp and report penalty
const total = computeTrustScore({
  profileRow: filledProfile({ ...fullOptional, profile_extras: fullExtras }),
  trustRow: {
    events_attended: 4,
    response_rate_pct: 100,
    positive_feedback_count: 5,
  },
  reportsCount: 1,
  mutualMatchCount: 5,
});
assert.equal(total.trustScore, 175, "150 + 50 - 25");
assert.equal(total.trustTier, "elite");

const capped = computeTrustScore({
  profileRow: filledProfile({ ...fullOptional, profile_extras: fullExtras }),
  trustRow: {
    events_attended: 4,
    response_rate_pct: 100,
    positive_feedback_count: 5,
  },
  reportsCount: 0,
  mutualMatchCount: 5,
});
assert.equal(capped.trustScore, 200);

console.log("trust.test.js: all assertions passed");
