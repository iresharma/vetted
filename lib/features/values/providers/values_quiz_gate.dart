import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/values_service.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_status_notifier.dart';

/// Returns true only when the member still needs to take or skip the values quiz.
bool isValuesQuizPending({
  ValuesQuizStatus? quizStatus,
  String? registrationValuesQuizStatus,
  String? cachedValuesQuizStatus,
}) {
  if (quizStatus != null) return quizStatus.isPending;

  if (cachedValuesQuizStatus != null) {
    return cachedValuesQuizStatus == 'pending';
  }

  if (registrationValuesQuizStatus != null) {
    return registrationValuesQuizStatus == 'pending';
  }

  // No local signal yet — assume pending until remote sync (new members).
  return true;
}

bool valuesQuizPending(WidgetRef ref) {
  final uid = ref.watch(authUidProvider);
  return isValuesQuizPending(
    quizStatus: ref.watch(valuesQuizStatusProvider).value,
    registrationValuesQuizStatus:
        ref.watch(registrationStatusProvider).value?.valuesQuizStatus,
    cachedValuesQuizStatus:
        uid != null ? LocalCache.readValuesQuizStatus(uid) : null,
  );
}

bool valuesQuizPendingFromRead(Ref ref) {
  final uid = ref.read(authUidProvider);
  return isValuesQuizPending(
    quizStatus: ref.read(valuesQuizStatusProvider).value,
    registrationValuesQuizStatus:
        ref.read(registrationStatusProvider).value?.valuesQuizStatus,
    cachedValuesQuizStatus:
        uid != null ? LocalCache.readValuesQuizStatus(uid) : null,
  );
}
