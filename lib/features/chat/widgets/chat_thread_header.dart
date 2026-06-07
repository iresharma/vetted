import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_user_avatar.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';

class ChatThreadHeader extends StatelessWidget {
  const ChatThreadHeader({
    super.key,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.onBack,
    this.onViewProfile,
    this.loadingProfile = false,
  });

  final String otherUserName;
  final String? otherUserPhotoUrl;
  final VoidCallback? onBack;
  final VoidCallback? onViewProfile;
  final bool loadingProfile;

  @override
  Widget build(BuildContext context) {
    final displayName = cleanDailyDisplayName(otherUserName);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(
                PhosphorIconsRegular.arrowLeft,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: loadingProfile ? null : onViewProfile,
                  borderRadius: AppRadius.r12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      children: [
                        ChatUserAvatar(
                          photoUrl: otherUserPhotoUrl,
                          name: displayName,
                          size: 52,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "It's mutual.",
                                style: AppTypography.eyebrow(
                                  color: AppColors.coral,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                displayName,
                                style: AppTypography.title(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (loadingProfile)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.coral,
                            ),
                          )
                        else
                          const Icon(
                            PhosphorIconsRegular.caretRight,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatEmptyConversation extends StatelessWidget {
  const ChatEmptyConversation({
    super.key,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  final String otherUserName;
  final String? otherUserPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final displayName = cleanDailyDisplayName(otherUserName);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChatUserAvatar(
              photoUrl: otherUserPhotoUrl,
              name: displayName,
              size: 80,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              "It's mutual.",
              style: AppTypography.headline(color: AppColors.coral).copyWith(
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You and $displayName both said yes.',
              textAlign: TextAlign.center,
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Say hi with something real — not just "hey".',
              textAlign: TextAlign.center,
              style: AppTypography.supporting(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
