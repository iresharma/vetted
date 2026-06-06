import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_field_mapper.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_progress.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_value_normalizer.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';

class ProfileSectionState {
  const ProfileSectionState({
    required this.formState,
    this.saving = false,
    this.error,
  });

  final ProfileFormState formState;
  final bool saving;
  final String? error;

  bool get canContinue =>
      !saving && ProfileValidator.isSectionValid(formState);

  double get progress => ProfileProgress.sectionProgress(formState);

  int get requiredRemaining =>
      ProfileValidator.requiredRemaining(formState);

  ProfileSectionState copyWith({
    ProfileFormState? formState,
    bool? saving,
    String? error,
    bool clearError = false,
  }) {
    return ProfileSectionState(
      formState: formState ?? this.formState,
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final profileSectionProvider = NotifierProvider.family<
    ProfileSectionNotifier, ProfileSectionState, String>(
  ProfileSectionNotifier.new,
);

class ProfileSectionNotifier extends Notifier<ProfileSectionState> {
  ProfileSectionNotifier(this._sectionId);

  final String _sectionId;
  ProfileSection? _section;
  bool _draftHydrated = false;

  @override
  ProfileSectionState build() {
    ref.listen(profileDraftProvider, (previous, next) {
      if (!next.hasValue || _section == null) return;
      final section = _section!;
      final draftValues = next.value?.values ?? {};
      Future.microtask(() {
        if (!ref.mounted) return;
        _hydrateFromDraft(section, draftValues);
      });
    });
    _bootstrap();
    return ProfileSectionState(
      formState: ProfileFormState(section: _placeholderSection(_sectionId)),
    );
  }

  void _hydrateFromDraft(ProfileSection section, Map<String, dynamic> draftValues) {
    if (draftValues.isEmpty && _draftHydrated) return;

    final merged = _mergeDraftValues(state.formState.values, draftValues);
    state = ProfileSectionState(
      formState: ProfileFormState(
        section: section,
        values: _normalizeHydratedValues(section, merged),
      ),
    );
    _draftHydrated = true;
  }

  Future<void> _bootstrap() async {
    final schema = await ref.read(profileSchemaProvider.future);
    final section = schema.sectionById(_sectionId);
    if (section == null) return;
    _section = section;

    final draftAsync = ref.read(profileDraftProvider);
    if (draftAsync.hasValue) {
      _hydrateFromDraft(section, draftAsync.value?.values ?? {});
    } else {
      state = ProfileSectionState(
        formState: ProfileFormState(section: section),
      );
    }
  }

  static bool _isFilledValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  Map<String, dynamic> _mergeDraftValues(
    Map<String, dynamic> current,
    Map<String, dynamic> draft,
  ) {
    if (current.isEmpty) return Map<String, dynamic>.from(draft);
    final merged = Map<String, dynamic>.from(draft);
    for (final entry in current.entries) {
      if (_isFilledValue(entry.value)) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  Map<String, dynamic> _normalizeHydratedValues(
    ProfileSection section,
    Map<String, dynamic> merged,
  ) {
    if (_sectionId != 'interests') return merged;

    ProfileField? weekendField;
    for (final field in section.allFields) {
      if (field.id == 'weekend_vibe') {
        weekendField = field;
        break;
      }
    }
    if (weekendField == null) return merged;

    final raw = merged['weekend_vibe'];
    if (raw is! List || raw.isEmpty) return merged;

    final canonical = ProfileValueNormalizer.canonicalizeWeekendVibes(
      saved: raw.map((e) => e.toString()).toList(),
      options: weekendField.options,
    );
    if (canonical.toString() == raw.toString()) return merged;
    return {...merged, 'weekend_vibe': canonical};
  }

  ProfileSection _placeholderSection(String id) {
    return ProfileSection(
      id: id,
      step: 0,
      title: '',
      subtitle: '',
      xpWeight: 25,
      fields: const [],
    );
  }

  void setValue(String fieldId, dynamic value) {
    final next = Map<String, dynamic>.from(state.formState.values);
    next[fieldId] = value;
    state = state.copyWith(
      formState: ProfileFormState(
        section: state.formState.section,
        values: next,
      ),
      clearError: true,
    );
  }

  Map<String, dynamic> _valuesForSave(ProfileSection section) {
    final uiValues = Map<String, dynamic>.from(state.formState.values);
    final draft = ref.read(profileDraftProvider).value;

    if (draft != null) {
      for (final field in section.allFields) {
        if (uiValues.containsKey(field.id)) continue;
        final draftValue = draft.values[field.id];
        if (_isFilledValue(draftValue)) {
          uiValues[field.id] = draftValue;
        }
      }
    }
    return uiValues;
  }

  Future<bool> save({bool requireValid = true}) async {
    if (_section == null) {
      final schema = await ref.read(profileSchemaProvider.future);
      _section = schema.sectionById(_sectionId);
    }
    final section = _section;
    if (section == null) return false;
    if (requireValid && !state.canContinue) return false;

    final uiValues = _valuesForSave(section);
    final dropped = ProfileFieldMapper.droppedFieldIds(
      section: section,
      uiValues: uiValues,
    );
    if (dropped.isNotEmpty) {
      state = state.copyWith(
        saving: false,
        error:
            'Some answers could not be saved (${dropped.join(', ')}). '
            'Try re-selecting them.',
      );
      return false;
    }

    final payload = ProfileFieldMapper.toApiPayload(
      section: section,
      uiValues: uiValues,
    );
    if (payload.isEmpty) {
      final hasFilled = uiValues.entries.any(
        (entry) => _isFilledValue(entry.value),
      );
      if (hasFilled) {
        state = state.copyWith(
          saving: false,
          error: 'Some answers could not be saved. Try re-selecting them.',
        );
        return false;
      }
      return !requireValid || state.canContinue;
    }

    state = state.copyWith(saving: true, clearError: true);
    try {
      final result =
          await ref.read(profileServiceProvider).saveFields(payload);
      ref.read(profileDraftProvider.notifier).applySectionSave(
            uiValues: uiValues,
            trustScore: result.trustScore,
            trustTier: result.trustTier,
            profilePoints: result.profilePoints,
            behaviorPoints: result.behaviorPoints,
            isLive: result.isLive,
          );
      state = state.copyWith(saving: false);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('profile section save failed ($_sectionId): $e');
      }
      state = state.copyWith(
        saving: false,
        error: 'Could not save. Check your connection and try again.',
      );
      return false;
    }
  }
}
