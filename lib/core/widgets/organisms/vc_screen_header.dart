import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_trust_badge.dart';
import 'package:vetted_club_mobile/core/widgets/molecules/vc_progress_pips.dart';
import 'package:vetted_club_mobile/core/widgets/molecules/vc_xp_bar.dart';

class VcScreenHeader extends StatelessWidget {
  const VcScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trustLabel,
    this.trustVariant = VcTrustBadgeVariant.violet,
    this.pipTotal = 5,
    this.pipCurrent = 0,
    this.xpProgress,
    this.showXpBar = true,
  });

  final String eyebrow;
  final String title;
  final String? trustLabel;
  final VcTrustBadgeVariant trustVariant;
  final int pipTotal;
  final int pipCurrent;
  final double? xpProgress;
  final bool showXpBar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: AppRadius.r10,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow, style: AppTypography.eyebrow()),
                      const SizedBox(height: 2),
                      Text(title, style: AppTypography.headerCount()),
                    ],
                  ),
                ),
                if (trustLabel != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      VcTrustBadge(
                        label: trustLabel!,
                        variant: trustVariant,
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 80,
                        child: VcProgressPips(
                          total: pipTotal,
                          currentIndex: pipCurrent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (showXpBar && xpProgress != null) ...[
              const SizedBox(height: AppSpacing.sm),
              VcXpBar(
                progress: xpProgress!,
                animateOnMount: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
