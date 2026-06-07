import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

/// Full-width tappable row for long deal-breaker option text.
class ValuesQuizOptionRow extends StatelessWidget {
  const ValuesQuizOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.violetDim : AppColors.s3,
          borderRadius: AppRadius.r8,
          border: Border.all(
            color: selected ? AppColors.violet : AppColors.border,
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.supporting(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ).copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: compact ? 12 : 13,
                  height: 1.25,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 14, color: AppColors.violet),
          ],
        ),
      ),
    );
  }
}
