import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/features/chat/chat_thread_screen.dart';

abstract final class ChatThreadLauncher {
  static Future<void> open(
    BuildContext context, {
    required String threadId,
    required String otherUserId,
    required String otherUserName,
    String? otherUserPhotoUrl,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatThreadScreen(
          threadId: threadId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPhotoUrl: otherUserPhotoUrl,
        ),
      ),
    );
  }
}
