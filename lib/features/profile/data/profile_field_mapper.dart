import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_field_registry.dart';

class ProfileFieldMapper {
  const ProfileFieldMapper._();

  static Map<String, dynamic> toApiPayload({
    required ProfileSection section,
    required Map<String, dynamic> uiValues,
  }) {
    final columns = <String, dynamic>{};
    final extras = <String, dynamic>{};

    for (final field in section.allFields) {
      if (!uiValues.containsKey(field.id)) continue;
      final raw = uiValues[field.id];
      if (!_isFilled(raw)) continue;

      final storage = ProfileFieldRegistry.storageFor(field.id);
      final dbKey = ProfileFieldRegistry.dbKeyFor(field.id);
      final mapped = _mapValue(field, raw, extras);

      if (mapped == null) continue;

      if (storage == ProfileFieldStorage.extras) {
        extras[field.id] = mapped;
      } else if (field.type == ProfileFieldType.prompt) {
        columns[dbKey] = mapped;
        final qKey = ProfileFieldRegistry.promptQuestionKey(field.id);
        if (qKey != null && field.promptText != null) {
          columns[qKey] = field.promptText;
        }
      } else {
        columns[dbKey] = mapped;
      }
    }

    if (extras.isNotEmpty) {
      columns['profile_extras'] = extras;
    }
    return columns;
  }

  /// UI field ids that were filled in the form but could not be mapped for save.
  static List<String> droppedFieldIds({
    required ProfileSection section,
    required Map<String, dynamic> uiValues,
  }) {
    final dropped = <String>[];
    final scratchExtras = <String, dynamic>{};

    for (final field in section.allFields) {
      if (!uiValues.containsKey(field.id)) continue;
      final raw = uiValues[field.id];
      if (!_isFilled(raw)) continue;
      if (_mapValue(field, raw, scratchExtras) == null) {
        dropped.add(field.id);
      }
    }
    return dropped;
  }

  static dynamic _mapValue(
    ProfileField field,
    dynamic raw,
    Map<String, dynamic> extras,
  ) {
    return switch (field.type) {
      ProfileFieldType.text ||
      ProfileFieldType.prompt ||
      ProfileFieldType.time ||
      ProfileFieldType.citySearch =>
        raw.toString().trim(),
      ProfileFieldType.number => int.tryParse(raw.toString()),
      ProfileFieldType.singleSelect =>
        _mapSingle(field.id, raw.toString(), extras),
      ProfileFieldType.multiSelect =>
        (raw as List).map((e) => e.toString()).toList(),
      ProfileFieldType.photoUpload =>
        (raw as List).map((e) => e.toString()).toList(),
    };
  }

  static dynamic _mapSingle(
    String fieldId,
    String label,
    Map<String, dynamic> extras,
  ) {
    final mapped = switch (fieldId) {
      'gender' => _genderValue(label),
      'marital_status' => _maritalValue(label),
      'grew_up_abroad' => _grewUpAbroadValue(label),
      'work_mode' => _workModeValue(label),
      'faith' => _faithValue(label),
      'family_structure' => _familyStructureValue(label),
      'family_involvement' => _familyInvolvementValue(label),
      'diet' => _dietValue(label),
      'drinking' || 'smoking' => _habitValue(label),
      'marriage_timeline' => _timelineValue(label),
      'wants_children' => _kidsValue(label),
      'willing_to_relocate' => _relocateValue(label, extras),
      'open_to_inter_faith' => _triBoolValue(label, extras, 'open_to_inter_faith_label'),
      'open_to_inter_community' =>
        _triBoolValue(label, extras, 'open_to_inter_community_label'),
      'horoscope_matters' => _horoscopeValue(label),
      _ => label,
    };

    if (mapped != null) return mapped;

    // Accept values already stored as DB enums (reload → save cycles).
    if (_isKnownDbValue(fieldId, label)) return label;

    return null;
  }

  static bool _isKnownDbValue(String fieldId, String value) => switch (fieldId) {
        'gender' =>
          {'man', 'woman', 'non_binary', 'prefer_not_to_say'}.contains(value),
        'marital_status' =>
          {'never_married', 'divorced', 'widowed', 'separated'}.contains(value),
        'work_mode' =>
          {'in_office', 'remote', 'hybrid', 'prefer_not_to_say'}.contains(value),
        'faith' => {
            'hindu',
            'muslim',
            'sikh',
            'christian',
            'jain',
            'buddhist',
            'agnostic',
            'atheist',
            'other',
            'prefer_not_to_say',
          }.contains(value),
        'family_structure' =>
          {'nuclear', 'joint', 'open_to_either'}.contains(value),
        'family_involvement' => {
            'parents_leading',
            'i_decide_they_know',
            'private_for_now',
          }.contains(value),
        'diet' => {
            'vegetarian',
            'non_vegetarian',
            'eggetarian',
            'jain',
            'vegan',
            'prefer_not_to_say',
          }.contains(value),
        'drinking' || 'smoking' =>
          {'never', 'socially', 'regularly', 'prefer_not_to_say'}.contains(value),
        'marriage_timeline' => {
            'within_6_months',
            'within_1_year',
            '1_to_2_years',
            '2_to_3_years',
            'exploring',
          }.contains(value),
        'wants_children' => {
            'want_kids',
            'open_to_kids',
            'do_not_want',
            'have_kids',
            'prefer_not_to_say',
          }.contains(value),
        _ => false,
      };

  static bool _isFilled(dynamic value) {
    if (value == null) return false;
    if (value is List) return value.isNotEmpty;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  static String? _genderValue(String label) => switch (label) {
        'Man' => 'man',
        'Woman' => 'woman',
        'Non-binary' => 'non_binary',
        'Prefer not to say' => 'prefer_not_to_say',
        _ => null,
      };

  static String? _maritalValue(String label) => switch (label) {
        'Never married' => 'never_married',
        'Divorced' => 'divorced',
        'Widowed' => 'widowed',
        'Separated' => 'separated',
        _ => null,
      };

  static bool? _grewUpAbroadValue(String label) => switch (label) {
        'No, grew up in India' => false,
        'Yes — currently abroad' || 'Yes — returned to India' => true,
        _ => null,
      };

  static String? _workModeValue(String label) => switch (label) {
        'In-office' => 'in_office',
        'Remote' => 'remote',
        'Hybrid' => 'hybrid',
        'Varies' || 'Prefer not to say' => 'prefer_not_to_say',
        _ => null,
      };

  static String? _faithValue(String label) => switch (label) {
        'Hindu' => 'hindu',
        'Muslim' => 'muslim',
        'Sikh' => 'sikh',
        'Christian' => 'christian',
        'Jain' => 'jain',
        'Buddhist' => 'buddhist',
        'Agnostic' => 'agnostic',
        'Atheist' => 'atheist',
        'Other' => 'other',
        'Prefer not to say' => 'prefer_not_to_say',
        _ => null,
      };

  static String? _familyStructureValue(String label) => switch (label) {
        'Nuclear' => 'nuclear',
        'Joint' => 'joint',
        'Open to either' => 'open_to_either',
        _ => null,
      };

  static String? _familyInvolvementValue(String label) => switch (label) {
        'Parents are actively involved and leading' => 'parents_leading',
        "They know I'm looking — I make the final call" => 'i_decide_they_know',
        'This is private for now' => 'private_for_now',
        _ => null,
      };

  static String? _dietValue(String label) => switch (label) {
        'Vegetarian' => 'vegetarian',
        'Non-vegetarian' => 'non_vegetarian',
        'Eggetarian' => 'eggetarian',
        'Jain (strict vegetarian)' => 'jain',
        'Vegan' => 'vegan',
        'Prefer not to say' => 'prefer_not_to_say',
        _ => null,
      };

  static String? _habitValue(String label) => switch (label) {
        'Never' => 'never',
        'Socially' => 'socially',
        'Regularly' => 'regularly',
        'Prefer not to say' => 'prefer_not_to_say',
        _ => null,
      };

  static String? _timelineValue(String label) => switch (label) {
        'Within 6 months' => 'within_6_months',
        'Within 1 year' => 'within_1_year',
        '1 to 2 years' => '1_to_2_years',
        '2 to 3 years' => '2_to_3_years',
        'Still exploring — no fixed timeline' => 'exploring',
        _ => null,
      };

  static String? _kidsValue(String label) => switch (label) {
        'Yes — I definitely want kids' => 'want_kids',
        'Open to it' => 'open_to_kids',
        'Not sure yet' => 'prefer_not_to_say',
        "No — I don't want children" => 'do_not_want',
        'I already have children' => 'have_kids',
        _ => null,
      };

  /// BOOLEAN column — "Possibly" stored as false with label in profile_extras.
  static bool? _relocateValue(String label, Map<String, dynamic> extras) =>
      switch (label) {
        "Yes — I'm flexible" => true,
        'No — I need to stay in my city' => false,
        'Possibly — depends on where' => () {
            extras['willing_to_relocate_label'] = label;
            return false;
          }(),
        _ => null,
      };

  static bool? _triBoolValue(
    String label,
    Map<String, dynamic> extras,
    String labelKey,
  ) =>
      switch (label) {
        'Yes' => true,
        'No' => false,
        'Depends on the person' => () {
            extras[labelKey] = label;
            return false;
          }(),
        _ => null,
      };

  static bool? _horoscopeValue(String label) => switch (label) {
        'Yes, it matters to me' ||
        "My family cares — I'll go with their view" =>
          true,
        'No' => false,
        _ => null,
      };
}
