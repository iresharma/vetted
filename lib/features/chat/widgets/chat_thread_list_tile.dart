import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_action_card.dart';
import 'package:vetted_club_mobile/features/chat/chat_thread_launcher.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';

class ChatThreadListTile extends StatelessWidget {
  const ChatThreadListTile({super.key, required this.thread});

  final ChatThreadPreview thread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: HomeActionCard(
        icon: PhosphorIconsRegular.chatCircle,
        iconColor: AppColors.coral,
        iconBackground: AppColors.coralDim,
        title: thread.otherUserName,
        subtitle: thread.lastMessage.isEmpty
            ? 'Say hi'
            : _truncate(thread.lastMessage),
        trailing: _Trailing(
          time: thread.lastMessageAt,
          unreadCount: thread.unreadCount,
        ),
        onTap: () => ChatThreadLauncher.open(
          context,
          threadId: thread.id,
          otherUserName: thread.otherUserName,
        ),
      ),
    );
  }

  String _truncate(String text) {
    if (text.length <= 60) return text;
    return '${text.substring(0, 57)}...';
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({this.time, required this.unreadCount});

  final DateTime? time;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (time != null)
          Text(
            _formatRelative(time!),
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 11),
          ),
        if (unreadCount > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: AppTypography.labelCaps(color: AppColors.bg)
                  .copyWith(fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }

  String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
