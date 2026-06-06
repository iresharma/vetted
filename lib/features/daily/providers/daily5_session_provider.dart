import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/services/values_service.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_status_notifier.dart';

class Daily5Session {
  const Daily5Session({
    required this.needsQuiz,
    this.queue,
    this.quizStatus,
  });

  final bool needsQuiz;
  final DailyQueueResponse? queue;
  final ValuesQuizStatus? quizStatus;
}

final daily5SessionProvider =
    AsyncNotifierProvider<Daily5SessionNotifier, Daily5Session?>(
  Daily5SessionNotifier.new,
);

class Daily5SessionNotifier extends AsyncNotifier<Daily5Session?> {
  bool _activating = false;

  @override
  Future<Daily5Session?> build() async => null;

  bool _isQuizPending() {
    final session = state.value;
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

  ValuesQuizStatus? _resolvedQuizStatus() {
    return ref.read(valuesQuizStatusProvider).value ??
        () {
          final reg = ref.read(registrationStatusProvider).value?.valuesQuizStatus;
          if (reg == null) return null;
          return ValuesQuizStatus(status: reg);
        }();
  }

  /// Loads quiz status + queue (when quiz is done) for the Daily 5 tab.
  Future<void> activate() async {
    if (_activating) return;

    final existing = state.value;
    if (existing != null && !state.hasError) {
      if (existing.needsQuiz || existing.queue != null) return;
    }

    // Instant quiz — no spinner, no network wait.
    if (_isQuizPending()) {
      state = AsyncData(
        Daily5Session(needsQuiz: true, quizStatus: _resolvedQuizStatus()),
      );
      _syncQuizStatusInBackground();
      return;
    }

    _activating = true;
    if (existing?.queue == null) {
      state = const AsyncLoading();
    }

    try {
      final queue = await DailyService.instance.getDailyQueue();
      state = AsyncData(
        Daily5Session(
          needsQuiz: false,
          queue: queue,
          quizStatus: _resolvedQuizStatus(),
        ),
      );
    } catch (error, stackTrace) {
      if (_isQuizPending()) {
        state = AsyncData(
          Daily5Session(needsQuiz: true, quizStatus: _resolvedQuizStatus()),
        );
      } else if (existing != null) {
        state = AsyncData(existing);
      } else {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _activating = false;
    }
  }

  void _syncQuizStatusInBackground() {
    Future(() async {
      try {
        await ref.read(valuesQuizStatusProvider.notifier).refresh();
        if (!_isQuizPending() && ref.mounted) {
          await activate();
        }
      } catch (_) {}
    });
  }

  Future<void> onQuizFinished(String status) async {
    ref.read(valuesQuizStatusProvider.notifier).markCompleted(status);
    _syncRegistrationQuizStatus(status);
    final previous = state.value;
    state = AsyncData(
      Daily5Session(
        needsQuiz: false,
        queue: previous?.queue,
        quizStatus: ValuesQuizStatus(status: status),
      ),
    );
    try {
      final queue = await DailyService.instance.getDailyQueue();
      state = AsyncData(
        Daily5Session(
          needsQuiz: false,
          queue: queue,
          quizStatus: ValuesQuizStatus(status: status),
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _syncRegistrationQuizStatus(String status) {
    final current = ref.read(registrationStatusProvider).value;
    if (current == null) return;
    ref.read(registrationStatusProvider.notifier).cache(
          RegistrationStatus(
            exists: current.exists,
            hasPaidEntryPass: current.hasPaidEntryPass,
            hasActiveSubscription: current.hasActiveSubscription,
            isIdentityVerified: current.isIdentityVerified,
            isRegistrationComplete: current.isRegistrationComplete,
            isProfileComplete: current.isProfileComplete,
            trustScore: current.trustScore,
            trustTier: current.trustTier,
            profilePoints: current.profilePoints,
            behaviorPoints: current.behaviorPoints,
            valuesQuizStatus: status,
          ),
        );
  }
}
