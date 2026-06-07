const dailyScoreFieldLabels = <String, String>{
  'marriage_timeline': 'Marriage timeline',
  'diet': 'Diet',
  'drinking': 'Drinking',
  'smoking': 'Smoking',
  'faith': 'Faith',
  'wants_children': 'Children',
  'family_structure': 'Family type',
  'family_involvement': 'Family involvement',
  'open_to_inter_faith': 'Inter-faith openness',
  'education_level': 'Education',
  'field_of_work': 'Career field',
  'work_mode': 'Work style',
  'partner_search_approach': 'Dating approach',
  'living_arrangement_post_marriage': 'Living after marriage',
  'spouse_working_preference': 'Spouse career',
  'weekend_vibe': 'Weekend vibe',
  'exercise_frequency': 'Exercise',
  'pet_preference': 'Pets',
  'travel_frequency': 'Travel',
  'city': 'City',
  'home_state': 'Home state',
  'willing_to_relocate': 'Relocation',
};

String dailyScoreFieldLabel(String fieldId) {
  final known = dailyScoreFieldLabels[fieldId];
  if (known != null) return known;
  return fieldId
      .replaceAll('_', ' ')
      .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase());
}

String formatDailyProfileValue(dynamic value) {
  if (value == null) return '—';
  if (value is bool) return value ? 'Yes' : 'No';
  if (value is List) {
    return value.map(formatDailyProfileValue).join(', ');
  }
  final text = value.toString().trim();
  if (text.isEmpty) return '—';
  if (text.contains('_')) {
    return text
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
  return text;
}

final _testPrefixPattern = RegExp(r'^\[TEST\]\s*');

String cleanDailyDisplayName(String? raw, {String fallback = 'Member'}) {
  final clean = (raw ?? '').replaceFirst(_testPrefixPattern, '').trim();
  return clean.isEmpty ? fallback : clean;
}

String dailyProfileInitial(String? raw, {String fallback = '?'}) {
  final clean = (raw ?? '').replaceFirst(_testPrefixPattern, '').trim();
  if (clean.isEmpty) return fallback;
  return clean[0].toUpperCase();
}

String dailyProfileFirstName(String? raw, {String fallback = 'Member'}) {
  final clean = cleanDailyDisplayName(raw, fallback: fallback);
  return clean.split(RegExp(r'[\s,]')).first;
}
