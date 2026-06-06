import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/trust_service.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_report.dart';

final trustReportProvider =
    AsyncNotifierProvider.family<TrustReportNotifier, TrustReport, String?>(
  TrustReportNotifier.new,
);

class TrustReportNotifier extends AsyncNotifier<TrustReport> {
  TrustReportNotifier(this.category);

  final String? category;
  bool _syncing = false;

  @override
  Future<TrustReport> build() async {
    final uid = ref.watch(authUidProvider);
    if (uid == null) {
      throw StateError('Trust report requires a signed-in user');
    }

    ref.listen(authUidProvider, (previous, next) {
      if (previous != next) ref.invalidateSelf();
    });

    final cached = LocalCache.readTrustReport(uid, category);
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
        final remote =
            await TrustService.instance.loadReport(category: category);
        await LocalCache.writeTrustReport(uid, category, remote);
        if (ref.mounted) state = AsyncData(remote);
      } catch (_) {
        // Keep showing cached data.
      } finally {
        _syncing = false;
      }
    });
  }

  Future<TrustReport> _fetchRemote(String uid) async {
    final remote = await TrustService.instance.loadReport(category: category);
    await LocalCache.writeTrustReport(uid, category, remote);
    return remote;
  }

  Future<void> refresh() async {
    final uid = ref.read(authUidProvider);
    if (uid == null) return;

    final previous = state.value;
    if (previous == null) state = const AsyncLoading();

    try {
      final remote = await TrustService.instance.loadReport(category: category);
      await LocalCache.writeTrustReport(uid, category, remote);
      state = AsyncData(remote);
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
    }
  }
}
