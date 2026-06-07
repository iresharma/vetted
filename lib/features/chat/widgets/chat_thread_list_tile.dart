import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/chat_thread_launcher.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';
import 'package:vetted_club_mobile/features/chat/utils/chat_formatters.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_user_avatar.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';

class ChatThreadListTile extends StatelessWidget {
  const ChatThreadListTile({super.key, required this.thread});

  final ChatThreadPreview thread;

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;
    final displayName = cleanDailyDisplayName(thread.otherUserName);
    final photoUrl = thread.otherUserPhotoUrl;
    final preview = thread.lastMessage.isEmpty
        ? 'Say hi — you both said yes'
        : _truncate(thread.lastMessage);

    final card = VcSoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          ChatUserAvatar(
            photoUrl: photoUrl,
            name: displayName,
            size: 48,
            highlightUnread: hasUnread,
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'MATCH',
                      style: AppTypography.labelCaps(color: AppColors.coral),
                    ),
                    if (hasUnread) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const _UnreadDot(),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title().copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.supporting(
                    color: hasUnread
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ).copyWith(
                    fontWeight:
                        hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (thread.lastMessageAt != null)
                Text(
                  ChatFormatters.relativeListTime(thread.lastMessageAt!),
                  style: AppTypography.statCaption(
                    color: hasUnread ? AppColors.coral : AppColors.textMuted,
                  ),
                ),
              if (hasUnread) ...[
                const SizedBox(height: AppSpacing.xs),
                _UnreadCountBadge(count: thread.unreadCount),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final resolvedPhoto = photoUrl?.trim();
            if (resolvedPhoto != null && resolvedPhoto.isNotEmpty) {
              unawaited(
                ChatService.instance.ensureMemberPhoto(
                  threadId: thread.id,
                  memberUid: thread.otherUserId,
                  photoUrl: resolvedPhoto,
                ),
              );
            }
            ChatThreadLauncher.open(
              context,
              threadId: thread.id,
              otherUserId: thread.otherUserId,
              otherUserName: thread.otherUserName,
              otherUserPhotoUrl: resolvedPhoto,
            );
          },
          borderRadius: AppRadius.r16,
          child: card,
        ),
      ),
    );
  }

  String _truncate(String text) {
    if (text.length <= 64) return text;
    return '${text.substring(0, 61)}...';
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.coral,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _UnreadCountBadge extends StatelessWidget {
  const _UnreadCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.chip(color: AppColors.onViolet).copyWith(
          fontSize: 10,
        ),
      ),
    );
  }
}
