import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';

final profileDraftProvider =
    AsyncNotifierProvider<ProfileDraftNotifier, ProfileDraft?>(
  ProfileDraftNotifier.new,
);

class ProfileDraftNotifier extends AsyncNotifier<ProfileDraft?> {
  bool _syncing = false;

  @override
  Future<ProfileDraft?> build() async {
    final uid = ref.watch(authUidProvider);
    if (uid == null) return null;

    ref.listen(authUidProvider, (previous, next) {
      if (previous != next) ref.invalidateSelf();
    });

    final cached = LocalCache.readProfileDraft(uid);
    if (cached != null) {
      _syncInBackground(uid);
      return cached;
    }

    return _fetchRemote(uid);
  }

  void _syncInBackground(String uid) {
    if (_syncing) return;
    _syncing = true;
    Future(() async {
      try {
        final remote = await ref.read(profileServiceProvider).loadDraft();
        await LocalCache.writeProfileDraft(uid, remote);
        if (ref.mounted) state = AsyncData(remote);
      } catch (_) {
        // Keep showing cached data.
      } finally {
        _syncing = false;
      }
    });
  }

  Future<ProfileDraft> _fetchRemote(String uid) async {
    final remote = await ref.read(profileServiceProvider).loadDraft();
    await LocalCache.writeProfileDraft(uid, remote);
    return remote;
  }

  Future<void> _persist(ProfileDraft draft) async {
    final uid = ref.read(authUidProvider);
    if (uid == null) return;
    await LocalCache.writeProfileDraft(uid, draft);
  }

  Future<void> reload({bool mergeWithLocal = true}) async {
    final uid = ref.read(authUidProvider);
    if (uid == null) return;

    final previous = state.value;
    if (previous == null) state = const AsyncLoading();

    try {
      final remote = await ref.read(profileServiceProvider).loadDraft();
      final result = !mergeWithLocal || previous == null
          ? remote
          : _mergeDrafts(remote: remote, local: previous);
      await LocalCache.writeProfileDraft(uid, result);
      state = AsyncData(result);
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  static ProfileDraft _mergeDrafts({
    required ProfileDraft remote,
    required ProfileDraft local,
  }) {
    final mergedValues = Map<String, dynamic>.from(remote.values);
    for (final entry in local.values.entries) {
      if (_isFilledValue(entry.value)) {
        mergedValues[entry.key] = entry.value;
      }
    }

    return remote.copyWith(
      values: mergedValues,
      trustScore: remote.trustScore > 0 ? remote.trustScore : local.trustScore,
      profilePoints: remote.profilePoints > 0
          ? remote.profilePoints
          : local.profilePoints,
      behaviorPoints: remote.behaviorPoints > 0
          ? remote.behaviorPoints
          : local.behaviorPoints,
      isLive: remote.isLive || local.isLive,
    );
  }

  void applySaveResult({
    required int trustScore,
    required String trustTier,
    required int profilePoints,
    required int behaviorPoints,
    required bool isLive,
  }) {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      trustScore: trustScore,
      trustTier: trustTier,
      profilePoints: profilePoints,
      behaviorPoints: behaviorPoints,
      isLive: isLive,
    );
    state = AsyncData(updated);
    _persist(updated);
  }

  /// Merges saved section values into the in-memory draft after a successful save.
  void applySectionSave({
    required Map<String, dynamic> uiValues,
    required int trustScore,
    required String trustTier,
    required int profilePoints,
    required int behaviorPoints,
    required bool isLive,
  }) {
    final current = state.value;
    final merged = Map<String, dynamic>.from(current?.values ?? {});
    for (final entry in uiValues.entries) {
      if (_isFilledValue(entry.value)) {
        merged[entry.key] = entry.value;
      }
    }

    final updated = ProfileDraft(
      verifiedName: current?.verifiedName,
      verifiedAge: current?.verifiedAge,
      trustScore: trustScore,
      trustTier: trustTier,
      profilePoints: profilePoints,
      behaviorPoints: behaviorPoints,
      isLive: isLive,
      values: merged,
      extras: current?.extras ?? const {},
    );
    state = AsyncData(updated);
    _persist(updated);
  }

  static bool _isFilledValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }
}

/// Total trust score (0–200).
final profileTrustScoreProvider = Provider<int>((ref) {
  return ref.watch(profileDraftProvider).value?.trustScore ?? 0;
});

/// Profile trust contribution (0–150).
final profilePointsProvider = Provider<int>((ref) {
  return ref.watch(profileDraftProvider).value?.profilePoints ?? 0;
});

/// Behavior trust contribution (0–50).
final profileBehaviorPointsProvider = Provider<int>((ref) {
  return ref.watch(profileDraftProvider).value?.behaviorPoints ?? 0;
});

/// @deprecated Use [profileTrustScoreProvider].
final profileCompletenessProvider = profileTrustScoreProvider;
