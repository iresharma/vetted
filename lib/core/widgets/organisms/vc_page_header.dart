import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Shared page header — eyebrow, title, optional subtitle and trailing actions.
class VcPageHeader extends StatelessWidget {
  const VcPageHeader({
    super.key,
    this.leading,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget? leading;
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  static const horizontalPadding = AppSpacing.screenHorizontal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.sm,
          horizontalPadding,
          AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.xxs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: AppTypography.eyebrow(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(title, style: AppTypography.headline()),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.supporting(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
