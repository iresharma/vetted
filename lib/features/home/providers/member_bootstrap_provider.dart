import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/features/daily/providers/daily5_session_provider.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/trust/providers/trust_report_provider.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_gate.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_status_notifier.dart';

/// Prefetches profile and trust when the member shell loads; warms Daily 5 in the background.
final memberBootstrapProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return;

  await Future.wait([
    ref.read(profileDraftProvider.future),
    ref.read(trustReportProvider(null).future),
    ref.read(registrationStatusProvider.notifier).refresh(uid),
    ref.read(valuesQuizStatusProvider.future).then((_) async {
      if (!valuesQuizPendingFromRead(ref)) {
        await ref.read(daily5SessionProvider.notifier).activate();
      }
    }),
  ]);
});
