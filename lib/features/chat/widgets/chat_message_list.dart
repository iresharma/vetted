import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_date_separator.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_message_bubble.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_swipe_to_reply.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.otherUserId,
    required this.onMessageReply,
    required this.onMessageLongPress,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String otherUserId;
  final ValueChanged<ChatMessage> onMessageReply;
  final ValueChanged<ChatMessage> onMessageLongPress;

  static const _groupGapMinutes = 3;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(messages);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return switch (item) {
          _DateItem(:final date) => ChatDateSeparator(date: date),
          _MessageItem(:final message, :final group) => ChatSwipeToReply(
              enabled: !message.deletedForEveryone,
              onReply: () => onMessageReply(message),
              child: ChatMessageBubble(
                message: message,
                otherUserId: otherUserId,
                isFirstInGroup: group.isFirst,
                isLastInGroup: group.isLast,
                showTimestamp: group.isLast,
                onLongPress: () => onMessageLongPress(message),
              ),
            ),
        };
      },
    );
  }

  List<_ListItem> _buildItems(List<ChatMessage> messages) {
    if (messages.isEmpty) return const [];

    final items = <_ListItem>[];
    DateTime? lastSeparatorDay;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final createdAt = message.createdAt;

      if (createdAt != null) {
        final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (lastSeparatorDay == null || day != lastSeparatorDay) {
          items.add(_DateItem(day));
          lastSeparatorDay = day;
        }
      }

      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      final isFirst = !_sameGroup(prev, message);
      final isLast = !_sameGroup(message, next);

      items.add(
        _MessageItem(
          message: message,
          group: _GroupPosition(isFirst: isFirst, isLast: isLast),
        ),
      );
    }

    return items;
  }

  bool _sameGroup(ChatMessage? a, ChatMessage? b) {
    if (a == null || b == null) return false;
    if (a.senderId != b.senderId) return false;

    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime == null || bTime == null) return true;

    return bTime.difference(aTime).inMinutes.abs() <= _groupGapMinutes;
  }
}

class _GroupPosition {
  const _GroupPosition({required this.isFirst, required this.isLast});

  final bool isFirst;
  final bool isLast;
}

sealed class _ListItem {}

class _DateItem extends _ListItem {
  _DateItem(this.date);

  final DateTime date;
}

class _MessageItem extends _ListItem {
  _MessageItem({required this.message, required this.group});

  final ChatMessage message;
  final _GroupPosition group;
}
