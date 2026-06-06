import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum HomeNudgeKind { verifyIdentity, completeProfile }

class HomeNudgeCard extends StatelessWidget {
  const HomeNudgeCard({
    super.key,
    required this.kind,
    required this.onTap,
  });

  final HomeNudgeKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, body, icon) = switch (kind) {
      HomeNudgeKind.verifyIdentity => (
          'Verify your identity',
          'Complete DigiLocker verification to unlock matching.',
          PhosphorIconsRegular.shieldWarning,
        ),
      HomeNudgeKind.completeProfile => (
          'Finish your profile',
          'Add the remaining details so you can go live on Daily 5.',
          PhosphorIconsRegular.userCircle,
        ),
    };

    return ClipRRect(
      borderRadius: AppRadius.r16,
      child: Material(
        color: AppColors.amberDim,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.amber.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.amber),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.title().copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(body, style: AppTypography.supporting()),
                    ],
                  ),
                ),
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
