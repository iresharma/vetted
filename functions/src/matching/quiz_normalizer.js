/** Maps values quiz UI labels to DB enum / column values. */

const LABEL_MAP = {
  diet: {
    Vegetarian: "vegetarian",
    "Non-vegetarian": "non_vegetarian",
    Eggetarian: "eggetarian",
    "Jain (strict vegetarian)": "jain",
    Vegan: "vegan",
  },
  drinking: {
    Never: "never",
    Socially: "socially",
    Regularly: "regularly",
  },
  smoking: {
    Never: "never",
    Socially: "socially",
    Regularly: "regularly",
  },
  faith: {
    Hindu: "hindu",
    Muslim: "muslim",
    Sikh: "sikh",
    Christian: "christian",
    Jain: "jain",
    Buddhist: "buddhist",
    Agnostic: "agnostic",
    Atheist: "atheist",
    Other: "other",
  },
  marriage_timeline: {
    "Within 6 months": "within_6_months",
    "Within 1 year": "within_1_year",
    "1 to 2 years": "1_to_2_years",
    "2 to 3 years": "2_to_3_years",
    "Still exploring — no fixed timeline": "exploring",
  },
  wants_children: {
    "Yes — I definitely want kids": "want_kids",
    "Open to it": "open_to_kids",
    "Not sure yet": "open_to_kids",
    "No — I don't want children": "do_not_want",
    "I already have children": "have_kids",
  },
  family_structure: {
    Nuclear: "nuclear",
    Joint: "joint",
    "Open to either": "open_to_either",
  },
  open_to_inter_faith: {
    Yes: "true",
    No: "false",
    "Depends on the person": "depends",
  },
};

function mapLabel(fieldId, label) {
  const mapped = LABEL_MAP[fieldId]?.[label];
  if (mapped) return mapped;
  return String(label).trim().toLowerCase().replace(/\s+/g, "_");
}

function normalizeQuizAnswers(raw) {
  const answers = JSON.parse(JSON.stringify(raw || {}));
  const acceptable = answers.dealbreakers?.acceptable;
  if (acceptable && typeof acceptable === "object") {
    const normalized = {};
    for (const [fieldId, values] of Object.entries(acceptable)) {
      if (!Array.isArray(values)) continue;
      normalized[fieldId] = values.map((v) => mapLabel(fieldId, v));
    }
    answers.dealbreakers.acceptable = normalized;
  }
  return answers;
}

module.exports = { normalizeQuizAnswers, mapLabel };
