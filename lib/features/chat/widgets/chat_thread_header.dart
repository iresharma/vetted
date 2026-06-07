import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';

class ChatThreadHeader extends StatelessWidget {
  const ChatThreadHeader({
    super.key,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.onBack,
  });

  final String otherUserName;
  final String? otherUserPhotoUrl;
  final VoidCallback? onBack;

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
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 48,
              child: Center(
                child: IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(
                    PhosphorIconsRegular.arrowLeft,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
            ChatUserAvatar(
              photoUrl: otherUserPhotoUrl,
              name: displayName,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Messages',
                    style: AppTypography.eyebrow(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: AppTypography.headline(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 44,
  });

  final String? photoUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = dailyProfileInitial(name);
    final url = photoUrl?.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 0.5),
        color: AppColors.s3,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover)
          : Center(
              child: Text(
                initial,
                style: AppTypography.title().copyWith(fontSize: size * 0.38),
              ),
            ),
    );
  }
}
