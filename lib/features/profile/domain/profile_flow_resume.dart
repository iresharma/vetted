import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';

/// Picks where to resume the profile flow from saved draft data.
abstract final class ProfileFlowResume {
  static const sectionOrder = [
    'you_and_photos',
    'interests',
    'career',
    'cultural',
  ];

  /// Returns the section id to open, or `null` if intro/new, `'complete'` if done.
  ///
  /// Uses a high-water-mark: find the furthest section the user has finished or
  /// started, then open the next incomplete step — so a missing weekend vibe
  /// does not send someone back to Rhythm if they already completed Career.
  static String? resumeTarget({
    required ProfileDraft? draft,
    required ProfileSchema schema,
  }) {
    if (draft == null || !_hasStarted(draft)) {
      return null;
    }

    var highWaterMark = -1;
    for (var i = 0; i < sectionOrder.length; i++) {
      final section = schema.sectionById(sectionOrder[i]);
      if (section == null) continue;
      if (_isSectionValid(section, draft.values) ||
          _sectionHasProgress(section, draft.values)) {
        highWaterMark = i;
      }
    }

    if (highWaterMark < 0) return null;

    final markSection = schema.sectionById(sectionOrder[highWaterMark]);
    if (markSection == null) return null;

    if (!_isSectionValid(markSection, draft.values)) {
      return sectionOrder[highWaterMark];
    }

    for (var i = highWaterMark + 1; i < sectionOrder.length; i++) {
      final section = schema.sectionById(sectionOrder[i]);
      if (section == null) continue;
      if (!_isSectionValid(section, draft.values)) {
        return sectionOrder[i];
      }
    }

    return 'complete';
  }

  static bool _isSectionValid(
    ProfileSection section,
    Map<String, dynamic> values,
  ) {
    return ProfileValidator.isSectionValid(
      ProfileFormState(section: section, values: values),
    );
  }

  static bool _sectionHasProgress(
    ProfileSection section,
    Map<String, dynamic> values,
  ) {
    for (final field in section.allFields) {
      if (ProfileValidator.isFieldFilled(field, values[field.id])) {
        return true;
      }
    }
    return false;
  }

  static bool _hasStarted(ProfileDraft draft) {
    if (draft.trustScore > 0 || draft.profilePoints > 0) return true;
    return draft.values.isNotEmpty;
  }
}

/// Restores the interests micro-flow step from saved field values.
abstract final class ProfileInterestsMicroResume {
  static int microStepIndex({
    required Map<String, dynamic> values,
    int minInterests = 3,
  }) {
    final interests = _asStringList(values['interests']);
    final weekend = _asStringList(values['weekend_vibe']);

    if (interests.length >= minInterests && weekend.isNotEmpty) {
      return 2;
    }
    if (interests.length >= minInterests) {
      return 1;
    }
    return 0;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }
}

/// Restores the career micro-flow step from saved field values.
abstract final class ProfileCareerMicroResume {
  static int microStepIndex({required Map<String, dynamic> values}) {
    final education = values['education_level']?.toString();
    final field = values['field_of_work']?.toString();
    final jobTitle = values['job_title']?.toString().trim() ?? '';

    if (education != null &&
        education.isNotEmpty &&
        field != null &&
        field.isNotEmpty &&
        jobTitle.isNotEmpty) {
      return 2;
    }
    if (education != null && education.isNotEmpty) {
      return 1;
    }
    return 0;
  }
}

/// Restores the cultural micro-flow step from saved field values.
abstract final class ProfileCulturalMicroResume {
  static int microStepIndex({required Map<String, dynamic> values}) {
    if (!_filled(values, 'faith') || !_filled(values, 'mother_tongue')) {
      return 0;
    }
    if (!_filled(values, 'family_structure') ||
        !_filled(values, 'family_involvement')) {
      return 1;
    }
    if (!_filled(values, 'diet') ||
        !_filled(values, 'drinking') ||
        !_filled(values, 'smoking')) {
      return 2;
    }
    return 3;
  }

  static bool _filled(Map<String, dynamic> values, String key) {
    final value = values[key]?.toString();
    return value != null && value.isNotEmpty;
  }
}
