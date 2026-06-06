import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/profile_service.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_field_mapper.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';

/// Merges in-memory section state into one draft and API payload.
abstract final class ProfileFlowFinalizer {
  static Map<String, dynamic> mergedUiValues(WidgetRef ref) {
    final merged = <String, dynamic>{};

    for (final sectionId in ProfileFlowResume.sectionOrder) {
      final sectionState = ref.read(profileSectionProvider(sectionId));
      for (final entry in sectionState.formState.values.entries) {
        if (_isFilled(entry.value)) {
          merged[entry.key] = entry.value;
        }
      }
    }

    final draft = ref.read(profileDraftProvider).value;
    if (draft != null) {
      for (final entry in draft.values.entries) {
        if (_isFilled(entry.value)) {
          merged[entry.key] = entry.value;
        }
      }
    }

    return merged;
  }

  static ProfileDraft mergedDraft(WidgetRef ref) {
    final existing = ref.read(profileDraftProvider).value;
    final values = mergedUiValues(ref);

    return ProfileDraft(
      verifiedName: existing?.verifiedName,
      verifiedAge: existing?.verifiedAge,
      trustScore: existing?.trustScore ?? 0,
      trustTier: existing?.trustTier ?? 'trusted',
      profilePoints: existing?.profilePoints ?? 0,
      behaviorPoints: existing?.behaviorPoints ?? 0,
      isLive: existing?.isLive ?? false,
      values: values,
      extras: existing?.extras ?? const {},
    );
  }

  static Map<String, dynamic> fullApiPayload({
    required ProfileSchema schema,
    required Map<String, dynamic> uiValues,
  }) {
    final columns = <String, dynamic>{};
    var extras = <String, dynamic>{};

    for (final sectionId in ProfileFlowResume.sectionOrder) {
      final section = schema.sectionById(sectionId);
      if (section == null) continue;

      final part = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: uiValues,
      );

      for (final entry in part.entries) {
        if (entry.key == 'profile_extras' && entry.value is Map) {
          extras = {
            ...extras,
            ...Map<String, dynamic>.from(entry.value as Map),
          };
        } else {
          columns[entry.key] = entry.value;
        }
      }
    }

    if (extras.isNotEmpty) {
      columns['profile_extras'] = extras;
    }
    return columns;
  }

  static Future<bool> flushToBackend(WidgetRef ref) async {
    final schema = await ref.read(profileSchemaProvider.future);
    final uiValues = mergedUiValues(ref);
    if (uiValues.isEmpty) return false;

    ProfileSaveResult? lastResult;
    var anySaved = false;

    for (final sectionId in ProfileFlowResume.sectionOrder) {
      final section = schema.sectionById(sectionId);
      if (section == null) continue;

      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: uiValues,
      );
      if (payload.isEmpty) continue;

      try {
        lastResult =
            await ref.read(profileServiceProvider).saveFields(payload);
        anySaved = true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Profile flush failed for $sectionId: $e');
        }
      }
    }

    if (!anySaved || lastResult == null) return false;

    ref.read(profileDraftProvider.notifier).applySectionSave(
          uiValues: uiValues,
          trustScore: lastResult.trustScore,
          trustTier: lastResult.trustTier,
          profilePoints: lastResult.profilePoints,
          behaviorPoints: lastResult.behaviorPoints,
          isLive: lastResult.isLive,
        );
    return true;
  }

  static bool _isFilled(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }
}
