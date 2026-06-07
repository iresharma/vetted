import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

class ValuesQuizStepHero extends StatelessWidget {
  const ValuesQuizStepHero({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.title().copyWith(
            fontSize: compact ? 17 : 20,
            height: 1.15,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          subtitle,
          style: AppTypography.supporting(
            color: AppColors.textMuted,
          ).copyWith(
            fontSize: compact ? 12 : 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
