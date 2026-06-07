import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

class ValuesQuizStepLifestyle extends StatelessWidget {
  const ValuesQuizStepLifestyle({
    super.key,
    required this.answers,
    required this.onChanged,
  });

  final ValuesQuizAnswers answers;
  final ValueChanged<ValuesQuizAnswers> onChanged;

  static const _icons = {
    'diet': PhosphorIconsRegular.forkKnife,
    'weekend_vibe': PhosphorIconsRegular.moonStars,
    'drinking': PhosphorIconsRegular.wine,
    'smoking': PhosphorIconsRegular.prohibit,
    'exercise_frequency': PhosphorIconsRegular.barbell,
    'pet_preference': PhosphorIconsRegular.pawPrint,
    'travel_frequency': PhosphorIconsRegular.airplaneTilt,
  };

  void _toggle(String id) {
    final top = List<String>.from(answers.lifestyleTopThree);
    final index = top.indexOf(id);
    if (index >= 0) {
      top.removeAt(index);
    } else if (top.length < 3) {
      top.add(id);
    } else {
      top.removeLast();
      top.add(id);
    }
    onChanged(answers.copyWith(lifestyleTopThree: top));
  }

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);
    final top = answers.lifestyleTopThree;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (top.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 10 : 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < top.length; i++)
                  _RankBadge(
                    rank: i + 1,
                    label: valuesLifestyleLabels[top[i]] ?? top[i],
                  ),
              ],
            ),
          ),
        for (final id in valuesLifestyleRankDefaults)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 6 : 8),
            child: _PriorityTile(
              label: valuesLifestyleLabels[id] ?? id,
              icon: _icons[id] ?? PhosphorIconsRegular.star,
              rank: top.contains(id) ? top.indexOf(id) + 1 : null,
              compact: compact,
              onTap: () => _toggle(id),
            ),
          ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.label});

  final int rank;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => AppColors.amber,
      2 => AppColors.violet,
      _ => AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.r20,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        '#$rank $label',
        style: AppTypography.chip(color: color).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.label,
    required this.icon,
    required this.rank,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int? rank;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = rank != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 10 : 11,
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
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.supporting(
                  color: selected ? AppColors.amber : AppColors.textPrimary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 13 : 14,
                ),
              ),
            ),
            if (rank != null)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: AppTypography.chip(color: AppColors.amber)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
