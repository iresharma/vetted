import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_constants.dart';

class ChatMessageActionSheet extends StatelessWidget {
  const ChatMessageActionSheet({
    super.key,
    required this.message,
    required this.onReply,
    required this.onReaction,
    this.onHideForMe,
    this.hideForMeLabel = 'Remove for me',
    this.onDeleteForEveryone,
    this.deleteForEveryoneEnabled = false,
    this.onDeleteForEveryoneDisabled,
  });

  final ChatMessage message;
  final VoidCallback onReply;
  final ValueChanged<String> onReaction;
  final VoidCallback? onHideForMe;
  final String hideForMeLabel;
  final VoidCallback? onDeleteForEveryone;
  final bool deleteForEveryoneEnabled;
  final VoidCallback? onDeleteForEveryoneDisabled;

  static Future<void> show(
    BuildContext context, {
    required ChatMessage message,
    required VoidCallback onReply,
    required ValueChanged<String> onReaction,
    VoidCallback? onHideForMe,
    String hideForMeLabel = 'Remove for me',
    VoidCallback? onDeleteForEveryone,
    bool deleteForEveryoneEnabled = false,
    VoidCallback? onDeleteForEveryoneDisabled,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChatMessageActionSheet(
        message: message,
        onReply: onReply,
        onReaction: onReaction,
        onHideForMe: onHideForMe,
        hideForMeLabel: hideForMeLabel,
        onDeleteForEveryone: onDeleteForEveryone,
        deleteForEveryoneEnabled: deleteForEveryoneEnabled,
        onDeleteForEveryoneDisabled: onDeleteForEveryoneDisabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canReact = !message.deletedForEveryone;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final myReaction =
        currentUid != null ? message.reactionFor(currentUid) : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (canReact) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final emoji in chatQuickReactionEmojis)
                    _ReactionButton(
                      emoji: emoji,
                      selected: myReaction == emoji,
                      onTap: () {
                        Navigator.pop(context);
                        onReaction(emoji);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _ActionTile(
              icon: PhosphorIconsRegular.arrowBendUpLeft,
              label: 'Reply',
              onTap: () {
                Navigator.pop(context);
                onReply();
              },
            ),
            if (onHideForMe != null)
              _ActionTile(
                icon: PhosphorIconsRegular.eyeSlash,
                label: hideForMeLabel,
                onTap: () {
                  Navigator.pop(context);
                  onHideForMe!();
                },
              ),
            if (onDeleteForEveryone != null)
              _ActionTile(
                icon: PhosphorIconsRegular.trash,
                label: 'Delete for everyone',
                destructive: deleteForEveryoneEnabled,
                enabled: deleteForEveryoneEnabled,
                subtitle: deleteForEveryoneEnabled
                    ? null
                    : 'Only available before the message is read',
                onTap: () async {
                  Navigator.pop(context);
                  if (!deleteForEveryoneEnabled) {
                    onDeleteForEveryoneDisabled?.call();
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.bg,
                      title: Text(
                        'Delete for everyone?',
                        style: AppTypography.title(),
                      ),
                      content: Text(
                        'This message will be removed for both of you. '
                        'You can only do this before it\'s read.',
                        style: AppTypography.body(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            'Cancel',
                            style: AppTypography.body(color: AppColors.textMuted),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Delete',
                            style: AppTypography.body(color: AppColors.coral),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) onDeleteForEveryone!();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.emoji,
    required this.onTap,
    this.selected = false,
  });

  final String emoji;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.coralDim : AppColors.s1,
      borderRadius: AppRadius.r8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r8,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.enabled = true,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final bool enabled;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.textMuted
        : destructive
            ? AppColors.coral
            : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r8,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.body(color: color),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: AppTypography.statCaption(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
