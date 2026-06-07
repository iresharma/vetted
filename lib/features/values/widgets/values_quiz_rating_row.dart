import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

/// Stacked label + 1–5 rating dots — fits narrow screens without overflow.
class ValuesQuizRatingRow extends StatelessWidget {
  const ValuesQuizRatingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String? minLabel;
  final String? maxLabel;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);
    final dotSize = compact ? 26.0 : 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.supporting().copyWith(
            fontWeight: FontWeight.w600,
            fontSize: compact ? 12 : 13,
            height: 1.25,
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 1 ? 0 : 3),
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: dotSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == i ? AppColors.violetDim : AppColors.s3,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: value == i ? AppColors.violet : AppColors.border,
                          width: value == i ? 1.2 : 0.5,
                        ),
                      ),
                      child: Text(
                        '$i',
                        style: AppTypography.chip(
                          color: value == i
                              ? AppColors.violet
                              : AppColors.textMuted,
                        ).copyWith(fontSize: compact ? 11 : 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (minLabel != null && maxLabel != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel!, style: AppTypography.chip(color: AppColors.textMuted)),
              Text(maxLabel!, style: AppTypography.chip(color: AppColors.textMuted)),
            ],
          ),
        ],
      ],
    );
  }
}
