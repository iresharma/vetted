/// Ordered steps for the values quiz — easy questions first, filters last.
const valuesQuizStepMeta = [
  (
    id: 'life_stage',
    headline: 'What matters more right now?',
    hint: 'Tap one — we\'ll move on automatically',
    autoAdvance: true,
  ),
  (
    id: 'lifestyle',
    headline: 'Pick your top 3 lifestyle priorities',
    hint: 'Tap in order — 1st matters most',
    autoAdvance: false,
  ),
  (
    id: 'family',
    headline: 'How important is family alignment?',
    hint: 'Slide to set the overall weight',
    autoAdvance: false,
  ),
  (
    id: 'dealbreakers',
    headline: 'Any absolute deal-breakers?',
    hint: 'Optional — skip anything you\'re flexible on',
    autoAdvance: false,
  ),
  (
    id: 'geography',
    headline: 'Where should we look?',
    hint: 'Last one — then your Daily 5 unlocks',
    autoAdvance: false,
  ),
];

int get valuesQuizStepCount => valuesQuizStepMeta.length;
