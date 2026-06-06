import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

/// Compact selectable tile for deal-breaker topics (2-column grid).
class ValuesQuizTopicTile extends StatelessWidget {
  const ValuesQuizTopicTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.amberDim : AppColors.s2,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: selected ? AppColors.amber : AppColors.border,
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: compact ? 16 : 18,
              color: selected ? AppColors.amber : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.supporting(
                  color: selected ? AppColors.amber : AppColors.textSecondary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 12,
                  height: 1.2,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: AppColors.amber,
              ),
          ],
        ),
      ),
    );
  }
}
