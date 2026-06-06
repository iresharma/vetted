import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

class ValuesQuizStepFamily extends StatelessWidget {
  const ValuesQuizStepFamily({
    super.key,
    required this.answers,
    required this.onChanged,
  });

  final ValuesQuizAnswers answers;
  final ValueChanged<ValuesQuizAnswers> onChanged;

  static const _labels = {
    1: 'Not a priority',
    2: 'Nice to have',
    3: 'Moderately important',
    4: 'Very important',
    5: 'Essential',
  };

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);
    final value = answers.familyAlignment;

    return VcSoftCard(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _labels[value] ?? 'Moderately important',
            style: AppTypography.title().copyWith(
              fontSize: compact ? 16 : 18,
              color: AppColors.violet,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: AppColors.violet,
              inactiveColor: AppColors.s3,
              onChanged: (v) =>
                  onChanged(answers.copyWith(familyAlignment: v.round())),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low', style: AppTypography.chip(color: AppColors.textMuted)),
              Text('High', style: AppTypography.chip(color: AppColors.textMuted)),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            'This sets how much family involvement, children, and living arrangements matter in your matches.',
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: compact ? 12 : 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
