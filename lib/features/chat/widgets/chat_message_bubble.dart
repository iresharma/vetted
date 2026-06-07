import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_constants.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';
import 'package:vetted_club_mobile/features/chat/utils/chat_formatters.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.otherUserId,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.showTimestamp = true,
    this.onLongPress,
  });

  final ChatMessage message;
  final String otherUserId;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTimestamp;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (message.deletedForEveryone) {
      return _DeletedSystemNotice(
        message: message,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
        showTimestamp: showTimestamp,
      );
    }

    final isMe = message.isFromCurrentUser;
    final isRead = isMe && message.isReadBy(otherUserId);

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
            child: GestureDetector(
              onLongPress: onLongPress,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _MessageContent(message: message, isMe: isMe),
                  if (message.reactionSummary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: _ReactionRow(
                        message: message,
                        isMe: isMe,
                      ),
                    ),
                  if (showTimestamp && message.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.xxs,
                        left: AppSpacing.xxs,
                        right: AppSpacing.xxs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ChatFormatters.messageTime(message.createdAt!),
                            style: AppTypography.statCaption(
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (isRead) ...[
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              'Read',
                              style: AppTypography.statCaption(
                                color: AppColors.coral,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isMe) const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    if (message.deletedForEveryone) {
      return const SizedBox.shrink();
    }

    final reply = message.replyTo;

    if (message.isGif) {
      return _GifBubble(
        url: message.gifUrl ?? '',
        previewUrl: message.gifPreviewUrl,
        aspectRatio: message.gifAspectRatio ?? 1,
        isMe: isMe,
        replyTo: reply,
      );
    }

    if (isMe) {
      return _SentBubble(text: message.text, replyTo: reply);
    }

    return _ReceivedBubble(text: message.text, replyTo: reply);
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({
    required this.replyTo,
    required this.isMe,
  });

  final ChatReplyPreview replyTo;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final preview = replyTo.text.trim().isEmpty
        ? chatReplyUnavailablePlaceholder
        : _truncate(replyTo.text);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.coral.withValues(alpha: 0.12)
            : AppColors.s2,
        borderRadius: AppRadius.r8,
        border: Border(
          left: BorderSide(
            color: isMe ? AppColors.coral : AppColors.textMuted,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyTo.senderName,
            style: AppTypography.statCaption(
              color: isMe ? AppColors.coral : AppColors.textSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _truncate(String text) {
    if (text.length <= 120) return text;
    return '${text.substring(0, 117)}…';
  }
}

class _ReactionRow extends StatelessWidget {
  const _ReactionRow({
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final myReaction =
        currentUid != null ? message.reactionFor(currentUid) : null;

    return Wrap(
      spacing: AppSpacing.xxs,
      children: [
        for (final entry in message.reactionSummary)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.s1,
              borderRadius: AppRadius.r8,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(
              entry.value > 1 ? '${entry.key} ${entry.value}' : entry.key,
              style: AppTypography.statCaption(
                color: myReaction == entry.key
                    ? AppColors.coral
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeletedSystemNotice extends StatelessWidget {
  const _DeletedSystemNotice({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showTimestamp,
  });

  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isFromCurrentUser;
    final label = isMe
        ? chatDeletedByYouMessage
        : chatDeletedByOtherMessage(message.senderName);

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.md : AppSpacing.xxs,
        bottom: isLastInGroup ? AppSpacing.xxs : 2,
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.s2,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xxs + 2,
                ),
                child: Text(
                  label,
                  style: AppTypography.eyebrow(color: AppColors.textMuted),
                ),
              ),
            ),
            if (showTimestamp && message.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  ChatFormatters.messageTime(message.createdAt!),
                  style: AppTypography.statCaption(color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GifBubble extends StatelessWidget {
  const _GifBubble({
    required this.url,
    required this.aspectRatio,
    required this.isMe,
    this.previewUrl,
    this.replyTo,
  });

  final String url;
  final String? previewUrl;
  final double aspectRatio;
  final bool isMe;
  final ChatReplyPreview? replyTo;

  static const _maxWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _GifError(isMe: isMe);
    }

    final image = ClipRRect(
      borderRadius: AppRadius.r12,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _GifPlaceholder(
            aspectRatio: aspectRatio,
            previewUrl: previewUrl,
            isMe: isMe,
          );
        },
        errorBuilder: (_, __, ___) => _GifError(isMe: isMe),
      ),
    );

    final sized = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: AspectRatio(
        aspectRatio: aspectRatio > 0 ? aspectRatio : 1,
        child: image,
      ),
    );

    Widget content = sized;
    if (replyTo != null && replyTo!.isValid) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReplyQuote(replyTo: replyTo!, isMe: isMe),
          sized,
        ],
      );
    }

    if (isMe) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: content,
      );
    }

    return VcSoftCard(
      padding: replyTo != null && replyTo!.isValid
          ? const EdgeInsets.all(AppSpacing.xs)
          : EdgeInsets.zero,
      child: content,
    );
  }
}

class _GifPlaceholder extends StatelessWidget {
  const _GifPlaceholder({
    required this.aspectRatio,
    required this.isMe,
    this.previewUrl,
  });

  final double aspectRatio;
  final bool isMe;
  final String? previewUrl;

  @override
  Widget build(BuildContext context) {
    final preview = previewUrl;
    return ColoredBox(
      color: isMe ? AppColors.coralDim : AppColors.s1,
      child: preview != null && preview.isNotEmpty
          ? Image.network(
              preview,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: VcLoadingIndicator(compact: true),
              ),
            )
          : const Center(
              child: VcLoadingIndicator(compact: true),
            ),
    );
  }
}

class _GifError extends StatelessWidget {
  const _GifError({required this.isMe});

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        'GIF unavailable',
        style: AppTypography.supporting(color: AppColors.textMuted),
      ),
    );

    if (isMe) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.coralDim,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        child: content,
      );
    }

    return VcSoftCard(child: content);
  }
}

class _SentBubble extends StatelessWidget {
  const _SentBubble({
    required this.text,
    this.replyTo,
  });

  final String text;
  final ChatReplyPreview? replyTo;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyTo != null && replyTo!.isValid)
              _ReplyQuote(replyTo: replyTo!, isMe: true),
            Text(
              text,
              style: AppTypography.body(color: AppColors.textPrimary).copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceivedBubble extends StatelessWidget {
  const _ReceivedBubble({
    required this.text,
    this.replyTo,
  });

  final String text;
  final ChatReplyPreview? replyTo;

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyTo != null && replyTo!.isValid)
            _ReplyQuote(replyTo: replyTo!, isMe: false),
          Text(
            text,
            style: AppTypography.body().copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
