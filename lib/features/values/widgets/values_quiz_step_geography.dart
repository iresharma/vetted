import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_choice_card.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

class ValuesQuizStepGeography extends StatelessWidget {
  const ValuesQuizStepGeography({
    super.key,
    required this.answers,
    required this.onChanged,
  });

  final ValuesQuizAnswers answers;
  final ValueChanged<ValuesQuizAnswers> onChanged;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValuesQuizChoiceCard(
          label: 'Open to any city',
          detail: 'Show me matches across India',
          icon: PhosphorIconsRegular.globeHemisphereEast,
          selected: !answers.sameCityOnly,
          onTap: () => onChanged(answers.copyWith(sameCityOnly: false)),
        ),
        const SizedBox(height: 10),
        ValuesQuizChoiceCard(
          label: 'Same city only',
          detail: 'Only people in my city',
          icon: PhosphorIconsRegular.mapPin,
          selected: answers.sameCityOnly,
          onTap: () => onChanged(answers.copyWith(sameCityOnly: true)),
        ),
        if (!answers.sameCityOnly) ...[
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          VcSoftCard(
            padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How open are you to relocating?',
                  style: AppTypography.supporting().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
                Slider(
                  value: answers.relocateImportance.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppColors.violet,
                  inactiveColor: AppColors.s3,
                  onChanged: (v) =>
                      onChanged(answers.copyWith(relocateImportance: v.round())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Not at all', style: AppTypography.chip(color: AppColors.textMuted)),
                    Text('Very open', style: AppTypography.chip(color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
