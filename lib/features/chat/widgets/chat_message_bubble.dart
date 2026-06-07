import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/utils/chat_formatters.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.showTimestamp = true,
  });

  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromCurrentUser;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.md : AppSpacing.xxs,
        bottom: isLastInGroup ? AppSpacing.xxs : 2,
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) const Spacer(flex: 1),
          Flexible(
            flex: 4,
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isMe)
                  _SentBubble(text: message.text)
                else
                  _ReceivedBubble(text: message.text),
                if (showTimestamp && message.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xxs,
                      left: AppSpacing.xxs,
                      right: AppSpacing.xxs,
                    ),
                    child: Text(
                      ChatFormatters.messageTime(message.createdAt!),
                      style: AppTypography.statCaption(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isMe) const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _SentBubble extends StatelessWidget {
  const _SentBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.coralDim,
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: AppColors.coral.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          text,
          style: AppTypography.body(color: AppColors.textPrimary).copyWith(
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ReceivedBubble extends StatelessWidget {
  const _ReceivedBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        text,
        style: AppTypography.body().copyWith(height: 1.5),
      ),
    );
  }
}
