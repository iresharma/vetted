import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
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

    final regStatus = ref.watch(registrationStatusProvider).value?.valuesQuizStatus;
    if (regStatus != null) {
      final fromReg = ValuesQuizStatus(status: regStatus);
      _syncInBackground(uid);
      return fromReg;
    }

    final cached = _readCached(uid);
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
        if (ref.mounted) state = AsyncData(remote);
      } catch (_) {
        // Keep cached value.
      }
    });
  }

  Future<ValuesQuizStatus> _fetchRemote(String uid) async {
    final remote = await ValuesService.instance.getQuizStatus();
    await _persist(uid, remote);
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
  }
}
