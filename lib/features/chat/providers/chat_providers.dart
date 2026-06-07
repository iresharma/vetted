import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';

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
