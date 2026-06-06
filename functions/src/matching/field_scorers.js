const { getFieldValue, TIMELINE_ORDER } = require("./field_registry");

function normalizeString(value) {
  if (value == null) return null;
  return String(value).trim().toLowerCase();
}

function exactMatchScore(a, b) {
  const na = normalizeString(a);
  const nb = normalizeString(b);
  if (!na || !nb) return null;
  return na === nb ? 1 : 0;
}

function orderedMatchScore(a, b, order) {
  const na = normalizeString(a);
  const nb = normalizeString(b);
  if (!na || !nb) return null;
  if (na === nb) return 1;
  const ia = order.indexOf(na);
  const ib = order.indexOf(nb);
  if (ia < 0 || ib < 0) return 0;
  const maxDist = order.length - 1;
  const dist = Math.abs(ia - ib);
  return Math.max(0, 1 - dist / maxDist);
}

function setOverlapScore(a, b) {
  const listA = Array.isArray(a) ? a.map(normalizeString).filter(Boolean) : [];
  const listB = Array.isArray(b) ? b.map(normalizeString).filter(Boolean) : [];
  if (listA.length === 0 || listB.length === 0) return null;
  const setB = new Set(listB);
  const overlap = listA.filter((x) => setB.has(x)).length;
  const union = new Set([...listA, ...listB]).size;
  return union === 0 ? 0 : overlap / union;
}

function booleanMatchScore(a, b) {
  if (a == null || b == null) return null;
  return Boolean(a) === Boolean(b) ? 1 : 0;
}

function cityMatchScore(a, b) {
  const na = normalizeString(a);
  const nb = normalizeString(b);
  if (!na || !nb) return null;
  if (na === nb) return 1;
  if (na.includes(nb) || nb.includes(na)) return 0.6;
  return 0;
}

function scoreField(fieldId, viewerProfile, candidateProfile) {
  const viewerVal = getFieldValue(viewerProfile, fieldId);
  const candidateVal = getFieldValue(candidateProfile, fieldId);

  switch (fieldId) {
    case "marriage_timeline":
      return orderedMatchScore(viewerVal, candidateVal, TIMELINE_ORDER);
    case "weekend_vibe":
      return setOverlapScore(viewerVal, candidateVal);
    case "willing_to_relocate":
      return booleanMatchScore(viewerVal, candidateVal);
    case "city":
    case "home_state":
      return cityMatchScore(viewerVal, candidateVal);
    default:
      return exactMatchScore(viewerVal, candidateVal);
  }
}

function passesHardFilter(fieldId, viewerProfile, candidateProfile, quizAnswers = {}) {
  const viewerVal = getFieldValue(viewerProfile, fieldId);
  const candidateVal = getFieldValue(candidateProfile, fieldId);
  if (candidateVal == null) return true;

  const acceptable = quizAnswers.dealbreakers?.acceptable?.[fieldId];
  if (acceptable && Array.isArray(acceptable) && acceptable.length > 0) {
    const normalized = acceptable.map(normalizeString);
    return normalized.includes(normalizeString(candidateVal));
  }

  if (viewerVal == null) return true;
  const score = scoreField(fieldId, viewerProfile, candidateProfile);
  return score === null || score >= 0.5;
}

module.exports = {
  scoreField,
  passesHardFilter,
  normalizeString,
};
