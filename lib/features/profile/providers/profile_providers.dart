import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/profile_service.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_schema_loader.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService.instance,
);

final registrationServiceProvider = Provider<RegistrationService>(
  (ref) => RegistrationService.instance,
);

final profileSchemaProvider = FutureProvider<ProfileSchema>((ref) async {
  return ProfileSchemaLoader.load();
});

final registrationStatusProvider =
    AsyncNotifierProvider<RegistrationStatusNotifier, RegistrationStatus?>(
  RegistrationStatusNotifier.new,
);

class RegistrationStatusNotifier extends AsyncNotifier<RegistrationStatus?> {
  @override
  Future<RegistrationStatus?> build() async {
    final uid = ref.watch(authUidProvider);
    if (uid == null) return null;

    ref.listen(authUidProvider, (previous, next) {
      if (previous != next) ref.invalidateSelf();
    });

    return LocalCache.readRegistrationStatus(uid);
  }

  Future<void> _persist(String uid, RegistrationStatus status) async {
    await LocalCache.writeRegistrationStatus(uid, status);
  }

  Future<RegistrationStatus> refresh(String uid) async {
    final previous = state.value;
    if (previous == null) state = const AsyncLoading();

    try {
      final status =
          await ref.read(registrationServiceProvider).refreshStatus(uid);
      await _persist(uid, status);
      state = AsyncData(status);
      return status;
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
        return previous;
      }
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void cache(RegistrationStatus status) {
    state = AsyncData(status);
    final uid = ref.read(authUidProvider);
    if (uid != null) {
      _persist(uid, status);
    }
  }
}
