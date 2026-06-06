import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_choice_card.dart';

class ValuesQuizStepLifeStage extends StatelessWidget {
  const ValuesQuizStepLifeStage({
    super.key,
    required this.answers,
    required this.onChanged,
    this.onSelected,
  });

  final ValuesQuizAnswers answers;
  final ValueChanged<ValuesQuizAnswers> onChanged;
  final VoidCallback? onSelected;

  static const _options = [
    (
      label: 'Career-first',
      detail: 'Growth & ambition lead',
      value: 0.15,
      icon: PhosphorIconsRegular.briefcase,
    ),
    (
      label: 'Balanced',
      detail: 'Both matter equally',
      value: 0.5,
      icon: PhosphorIconsRegular.scales,
    ),
    (
      label: 'Marriage-first',
      detail: 'Ready to settle down',
      value: 0.85,
      icon: PhosphorIconsRegular.heart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bias = answers.careerVsTimeline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ValuesQuizChoiceCard(
              label: option.label,
              detail: option.detail,
              icon: option.icon,
              selected: (bias - option.value).abs() < 0.2,
              onTap: () {
                onChanged(answers.copyWith(careerVsTimeline: option.value));
                onSelected?.call();
              },
            ),
          ),
      ],
    );
  }
}
