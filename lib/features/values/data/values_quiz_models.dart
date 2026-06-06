/// Deal-breaker fields for values quiz step 1.
const valuesDealbreakerFields = [
  (
    id: 'diet',
    label: 'Diet',
    options: ['Vegetarian', 'Non-vegetarian', 'Eggetarian', 'Jain (strict vegetarian)', 'Vegan'],
  ),
  (
    id: 'drinking',
    label: 'Drinking',
    options: ['Never', 'Socially', 'Regularly'],
  ),
  (
    id: 'smoking',
    label: 'Smoking',
    options: ['Never', 'Socially', 'Regularly'],
  ),
  (
    id: 'faith',
    label: 'Faith',
    options: ['Hindu', 'Muslim', 'Sikh', 'Christian', 'Jain', 'Buddhist', 'Agnostic', 'Atheist', 'Other'],
  ),
  (
    id: 'marriage_timeline',
    label: 'Marriage timeline',
    options: [
      'Within 6 months',
      'Within 1 year',
      '1 to 2 years',
      '2 to 3 years',
      'Still exploring — no fixed timeline',
    ],
  ),
  (
    id: 'wants_children',
    label: 'Children',
    options: [
      'Yes — I definitely want kids',
      'Open to it',
      'Not sure yet',
      'No — I don\'t want children',
      'I already have children',
    ],
  ),
  (
    id: 'family_structure',
    label: 'Family type',
    options: ['Nuclear', 'Joint', 'Open to either'],
  ),
  (
    id: 'open_to_inter_faith',
    label: 'Inter-faith openness',
    options: ['Yes', 'No', 'Depends on the person'],
  ),
];

const valuesLifestyleRankDefaults = [
  'diet',
  'weekend_vibe',
  'drinking',
  'smoking',
  'exercise_frequency',
  'pet_preference',
  'travel_frequency',
];

const valuesLifestyleLabels = {
  'diet': 'Diet',
  'weekend_vibe': 'Weekend vibe',
  'drinking': 'Drinking',
  'smoking': 'Smoking',
  'exercise_frequency': 'Fitness',
  'pet_preference': 'Pets',
  'travel_frequency': 'Travel',
};

const valuesFamilyFields = [
  ('family_involvement', 'Family involvement in search'),
  ('family_structure', 'Family type preference'),
  ('living_arrangement_post_marriage', 'Living after marriage'),
  ('wants_children', 'Children preference'),
  ('spouse_working_preference', 'Spouse career expectations'),
];

class ValuesQuizAnswers {
  ValuesQuizAnswers({
    this.dealbreakerSelected = const {},
    this.dealbreakerAcceptable = const {},
    this.careerVsTimeline = 0.5,
    this.familyAlignment = 3,
    this.familyImportance = const {},
    this.lifestyleTopThree = const [],
    this.lifestyleRanked = valuesLifestyleRankDefaults,
    this.sameCityOnly = false,
    this.relocateImportance = 3,
    this.preferredCities = const [],
  });

  final Set<String> dealbreakerSelected;
  final Map<String, List<String>> dealbreakerAcceptable;
  final double careerVsTimeline;
  /// Single slider mapped to all family fields in [toPayload].
  final int familyAlignment;
  final Map<String, int> familyImportance;
  /// Ordered picks (max 3) for lifestyle ranking.
  final List<String> lifestyleTopThree;
  final List<String> lifestyleRanked;
  final bool sameCityOnly;
  final int relocateImportance;
  final List<String> preferredCities;

  List<String> _resolvedLifestyleRanked() {
    if (lifestyleTopThree.isEmpty) return lifestyleRanked;
    final rest = lifestyleRanked
        .where((id) => !lifestyleTopThree.contains(id))
        .toList();
    return [...lifestyleTopThree, ...rest];
  }

  Map<String, int> _resolvedFamilyImportance() {
    if (familyImportance.isNotEmpty) return familyImportance;
    return {
      for (final (id, _) in valuesFamilyFields) id: familyAlignment,
    };
  }

  Map<String, dynamic> toPayload() => {
        'dealbreakers': {
          'selected': dealbreakerSelected.toList(),
          'acceptable': dealbreakerAcceptable,
        },
        'lifeStage': {'careerVsTimeline': careerVsTimeline},
        'family': {'importance': _resolvedFamilyImportance()},
        'lifestyle': {'ranked': _resolvedLifestyleRanked()},
        'geography': {
          'sameCityOnly': sameCityOnly,
          'relocateImportance': relocateImportance,
          'preferredCities': preferredCities,
        },
      };

  ValuesQuizAnswers copyWith({
    Set<String>? dealbreakerSelected,
    Map<String, List<String>>? dealbreakerAcceptable,
    double? careerVsTimeline,
    int? familyAlignment,
    Map<String, int>? familyImportance,
    List<String>? lifestyleTopThree,
    List<String>? lifestyleRanked,
    bool? sameCityOnly,
    int? relocateImportance,
    List<String>? preferredCities,
  }) {
    return ValuesQuizAnswers(
      dealbreakerSelected: dealbreakerSelected ?? this.dealbreakerSelected,
      dealbreakerAcceptable:
          dealbreakerAcceptable ?? this.dealbreakerAcceptable,
      careerVsTimeline: careerVsTimeline ?? this.careerVsTimeline,
      familyAlignment: familyAlignment ?? this.familyAlignment,
      familyImportance: familyImportance ?? this.familyImportance,
      lifestyleTopThree: lifestyleTopThree ?? this.lifestyleTopThree,
      lifestyleRanked: lifestyleRanked ?? this.lifestyleRanked,
      sameCityOnly: sameCityOnly ?? this.sameCityOnly,
      relocateImportance: relocateImportance ?? this.relocateImportance,
      preferredCities: preferredCities ?? this.preferredCities,
    );
  }
}
