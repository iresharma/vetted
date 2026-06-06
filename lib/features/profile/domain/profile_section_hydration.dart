import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';

/// True when the section provider has merged remote draft data it depends on.
abstract final class ProfileSectionHydration {
  static bool isReady({
    required WidgetRef ref,
    required String sectionId,
    List<String> probeKeys = const [],
  }) {
    final draftAsync = ref.watch(profileDraftProvider);
    if (draftAsync.isLoading) return false;

    final sectionState = ref.read(profileSectionProvider(sectionId));
    final section = sectionState.formState.section;
    if (section.allFields.isEmpty) return false;

    final draft = draftAsync.value;
    if (draft == null || probeKeys.isEmpty) return true;

    final sectionValues = sectionState.formState.values;
    for (final key in probeKeys) {
      final draftValue = draft.values[key];
      if (!_isFilled(draftValue)) continue;

      final sectionValue = sectionValues[key];
      if (!_isFilled(sectionValue)) return false;

      if (draftValue is List && sectionValue is List) {
        if (draftValue.length != sectionValue.length) return false;
      }
    }

    return true;
  }

  static bool _isFilled(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }
}

/// Default draft probe keys per profile section.
abstract final class ProfileSectionProbeKeys {
  static const youAndPhotos = [
    'display_name',
    'gender',
    'city',
    'photo_urls',
  ];

  static const interests = [
    'interests',
    'weekend_vibe',
  ];

  static const career = [
    'education_level',
    'job_title',
    'field_of_work',
  ];

  static const cultural = [
    'faith',
    'mother_tongue',
    'family_structure',
    'diet',
    'marriage_timeline',
  ];
}
