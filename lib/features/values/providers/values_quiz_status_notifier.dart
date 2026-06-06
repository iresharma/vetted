import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/services/values_service.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';

final valuesQuizStatusProvider =
    AsyncNotifierProvider<ValuesQuizStatusNotifier, ValuesQuizStatus?>(
  ValuesQuizStatusNotifier.new,
);

class ValuesQuizStatusNotifier extends AsyncNotifier<ValuesQuizStatus?> {
  @override
  Future<ValuesQuizStatus?> build() async {
    final uid = ref.watch(authUidProvider);
    if (uid == null) return null;

    ref.listen(authUidProvider, (previous, next) {
      if (previous != next) ref.invalidateSelf();
    });

    final cached = _readCached(uid);
    if (cached != null && cached.isComplete) {
      _syncInBackground(uid);
      return cached;
    }

    final regStatus = ref.watch(registrationStatusProvider).value?.valuesQuizStatus;
    if (regStatus != null && regStatus != 'pending') {
      final fromReg = ValuesQuizStatus(status: regStatus);
      await _persist(uid, fromReg);
      _syncInBackground(uid);
      return fromReg;
    }

    if (cached != null) {
      _syncInBackground(uid);
      return cached;
    }

    return _fetchRemote(uid);
  }

  ValuesQuizStatus? _readCached(String uid) {
    final raw = LocalCache.readValuesQuizStatus(uid);
    if (raw == null) return null;
    return ValuesQuizStatus(status: raw);
  }

  Future<void> _persist(String uid, ValuesQuizStatus status) async {
    await LocalCache.writeValuesQuizStatus(uid, status.status);
  }

  void _syncInBackground(String uid) {
    Future(() async {
      try {
        final remote = await ValuesService.instance.getQuizStatus();
        await _persist(uid, remote);
        if (ref.mounted) {
          state = AsyncData(remote);
          if (!remote.isPending) {
            _syncRegistration(remote.status);
          }
        }
      } catch (_) {
        // Keep cached value.
      }
    });
  }

  void _syncRegistration(String status) {
    final current = ref.read(registrationStatusProvider).value;
    if (current == null || current.valuesQuizStatus == status) return;
    ref.read(registrationStatusProvider.notifier).cache(
          current.copyWithValuesQuizStatus(status),
        );
  }

  Future<ValuesQuizStatus> _fetchRemote(String uid) async {
    final remote = await ValuesService.instance.getQuizStatus();
    await _persist(uid, remote);
    if (!remote.isPending) {
      _syncRegistration(remote.status);
    }
    return remote;
  }

  Future<ValuesQuizStatus> refresh() async {
    final uid = ref.read(authUidProvider);
    if (uid == null) {
      throw StateError('Values quiz status requires a signed-in user');
    }

    final previous = state.value;
    if (previous == null) state = const AsyncLoading();

    try {
      final remote = await ValuesService.instance.getQuizStatus();
      await _persist(uid, remote);
      state = AsyncData(remote);
      if (!remote.isPending) {
        _syncRegistration(remote.status);
      }
      return remote;
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
        return previous;
      }
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void markCompleted(String status) {
    final uid = ref.read(authUidProvider);
    if (uid == null) return;
    final next = ValuesQuizStatus(status: status);
    state = AsyncData(next);
    _persist(uid, next);
    _syncRegistration(status);
  }
}

extension on RegistrationStatus {
  RegistrationStatus copyWithValuesQuizStatus(String status) {
    return RegistrationStatus(
      exists: exists,
      hasPaidEntryPass: hasPaidEntryPass,
      hasActiveSubscription: hasActiveSubscription,
      isIdentityVerified: isIdentityVerified,
      isRegistrationComplete: isRegistrationComplete,
      isProfileComplete: isProfileComplete,
      trustScore: trustScore,
      trustTier: trustTier,
      profilePoints: profilePoints,
      behaviorPoints: behaviorPoints,
      valuesQuizStatus: status,
    );
  }
}
