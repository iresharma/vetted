import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

class ValuesQuizChoiceCard extends StatelessWidget {
  const ValuesQuizChoiceCard({
    super.key,
    required this.label,
    required this.detail,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.violetDim : AppColors.s2,
          borderRadius: AppRadius.r14,
          border: Border.all(
            color: selected ? AppColors.violet : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: compact ? 40 : 44,
              height: compact ? 40 : 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.violet.withValues(alpha: 0.18)
                    : AppColors.s3,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: compact ? 20 : 22,
                color: selected ? AppColors.violet : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.supporting(
                      color: selected ? AppColors.violet : AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 14 : 15,
                    ),
                  ),
                  Text(
                    detail,
                    style: AppTypography.chip(color: AppColors.textMuted)
                        .copyWith(fontSize: compact ? 11 : 12),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.violet,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
