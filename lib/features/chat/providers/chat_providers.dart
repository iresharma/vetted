import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';
import 'package:vetted_club_mobile/features/daily/providers/daily5_session_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService.instance;
});

final chatThreadsStreamProvider =
    StreamProvider<List<ChatThreadPreview>>((ref) {
  final auth = ref.watch(authUserProvider);
  final uid = auth.value?.uid;
  if (uid == null) {
    if (auth.isLoading) return const Stream.empty();
    return Stream.value(const []);
  }

  return ChatService.instance.watchThreads(uid);
});

Map<String, String> _dailyQueuePhotos(Ref ref) {
  final dailyQueue = ref.watch(daily5SessionProvider).value?.queue;
  if (dailyQueue == null) return const {};

  final photoByUid = <String, String>{};
  for (final entry in dailyQueue.entries) {
    final photo = entry.profile.primaryPhoto;
    if (photo != null && photo.isNotEmpty) {
      photoByUid[entry.profile.uid] = photo;
    }
  }
  return photoByUid;
}

/// Resolves missing match photos from Daily 5 cache, then the backend.
final _threadPhotoBackfillProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final threads = ref.watch(chatThreadsStreamProvider).value ?? [];
  if (threads.isEmpty) return const {};

  final dailyPhotos = _dailyQueuePhotos(ref);
  final resolved = <String, String>{};

  for (final thread in threads) {
    final stored = thread.otherUserPhotoUrl?.trim();
    if (stored != null && stored.isNotEmpty) {
      resolved[thread.otherUserId] = stored;
      continue;
    }

    final cached = dailyPhotos[thread.otherUserId];
    if (cached != null && cached.isNotEmpty) {
      resolved[thread.otherUserId] = cached;
      unawaited(
        ChatService.instance.ensureMemberPhoto(
          threadId: thread.id,
          memberUid: thread.otherUserId,
          photoUrl: cached,
        ),
      );
      continue;
    }

    try {
      final profile =
          await DailyService.instance.getMatchProfile(thread.otherUserId);
      final photo = profile.primaryPhoto?.trim();
      if (photo == null || photo.isEmpty) continue;

      resolved[thread.otherUserId] = photo;
      unawaited(
        ChatService.instance.ensureMemberPhoto(
          threadId: thread.id,
          memberUid: thread.otherUserId,
          photoUrl: photo,
        ),
      );
    } catch (_) {
      // Keep initials fallback when profile lookup is unavailable.
    }
  }

  return resolved;
});

/// Threads with profile photos resolved from Firestore, Daily 5, or backend.
final enrichedChatThreadsProvider =
    Provider<AsyncValue<List<ChatThreadPreview>>>((ref) {
  final threadsAsync = ref.watch(chatThreadsStreamProvider);
  final photosAsync = ref.watch(_threadPhotoBackfillProvider);

  return threadsAsync.when(
    data: (threads) {
      final photoByUid = photosAsync.value ?? const {};
      return AsyncData([
        for (final thread in threads) _threadWithResolvedPhoto(thread, photoByUid),
      ]);
    },
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});

ChatThreadPreview _threadWithResolvedPhoto(
  ChatThreadPreview thread,
  Map<String, String> photoByUid,
) {
  final existing = thread.otherUserPhotoUrl?.trim();
  if (existing != null && existing.isNotEmpty) return thread;

  final fallback = photoByUid[thread.otherUserId];
  if (fallback == null || fallback.isEmpty) return thread;

  return thread.copyWith(otherUserPhotoUrl: fallback);
}

DailyProfileSummary? _profileFromDailyQueue(
  Ref ref,
  String otherUserId,
) {
  final photos = _dailyQueuePhotos(ref);
  final photo = photos[otherUserId];
  if (photo == null) return null;

  final queue = ref.read(daily5SessionProvider).value?.queue;
  if (queue == null) return null;

  for (final entry in queue.entries) {
    if (entry.profile.uid == otherUserId) {
      return entry.profile;
    }
  }
  return null;
}

/// Full profile for a chat match — Daily 5 cache first, then backend lookup.
final chatMatchProfileProvider =
    FutureProvider.family<DailyProfileSummary, String>((ref, otherUserId) async {
  if (otherUserId.isEmpty) {
    throw StateError('Missing match user id.');
  }

  final cached = _profileFromDailyQueue(ref, otherUserId);
  if (cached != null) return cached;

  return DailyService.instance.getMatchProfile(otherUserId);
});

final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, threadId) {
  final auth = ref.watch(authUserProvider);
  final uid = auth.value?.uid;
  if (uid == null) {
    if (auth.isLoading) return const Stream.empty();
    return Stream.value(const []);
  }

  return ChatService.instance.watchMessages(uid, threadId);
});

final hasUnreadChatsProvider = Provider<bool>((ref) {
  final threads = ref.watch(chatThreadsStreamProvider).value ?? [];
  return threads.any((t) => t.unreadCount > 0);
});
