import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class TrustBucketCard extends StatelessWidget {
  const TrustBucketCard({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int value;
  final int max;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final remaining = (max - value).clamp(0, max);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r16,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r16,
            border: Border.all(color: accent.withValues(alpha: 0.25), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(label, style: AppTypography.labelCaps(color: accent)),
                    ),
                    Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$value / $max',
                  style: AppTypography.title(color: accent).copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  remaining == 0 ? 'Maxed out' : '$remaining pts available',
                  style: AppTypography.supporting(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                VcXpBar(progress: progress, height: 5, animateOnMount: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
