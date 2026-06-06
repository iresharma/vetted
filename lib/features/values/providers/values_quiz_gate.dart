import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/features/daily/providers/daily5_session_provider.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_status_notifier.dart';

/// Whether the member still needs to complete (or skip) the values quiz.
bool valuesQuizPending(WidgetRef ref) {
  final session = ref.watch(daily5SessionProvider).value;
  if (session?.needsQuiz == true) return true;

  final regStatus = ref.watch(registrationStatusProvider).value?.valuesQuizStatus;
  if (regStatus == null || regStatus == 'pending') return true;

  final quizStatus = ref.watch(valuesQuizStatusProvider).value;
  if (quizStatus?.isPending == true) return true;

  final uid = ref.watch(authUidProvider);
  if (uid != null) {
    final cached = LocalCache.readValuesQuizStatus(uid);
    if (cached == null || cached == 'pending') return true;
  }

  return false;
}

bool valuesQuizPendingFromRead(Ref ref) {
  final session = ref.read(daily5SessionProvider).value;
  if (session?.needsQuiz == true) return true;

  final regStatus = ref.read(registrationStatusProvider).value?.valuesQuizStatus;
  if (regStatus == null || regStatus == 'pending') return true;

  final quizStatus = ref.read(valuesQuizStatusProvider).value;
  if (quizStatus?.isPending == true) return true;

  final uid = ref.read(authUidProvider);
  if (uid != null) {
    final cached = LocalCache.readValuesQuizStatus(uid);
    if (cached == null || cached == 'pending') return true;
  }

  return false;
}
