import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcPipState { done, current, upcoming }

class VcProgressPips extends StatelessWidget {
  const VcProgressPips({
    super.key,
    required this.total,
    required this.currentIndex,
    this.title,
    this.showPercentage = false,
    this.progress,
  });

  final int total;
  final int currentIndex;
  final String? title;
  final bool showPercentage;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final pct = progress ?? (currentIndex + 1) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null || showPercentage)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTypography.eyebrow(color: AppColors.violet),
                ),
              if (showPercentage)
                Text(
                  '${(pct * 100).round()}%',
                  style: AppTypography.chip(color: AppColors.amber),
                ),
            ],
          ),
        if (title != null || showPercentage) const SizedBox(height: AppSpacing.xs),
        Row(
          children: List.generate(total, (index) {
            final state = index < currentIndex
                ? VcPipState.done
                : index == currentIndex
                    ? VcPipState.current
                    : VcPipState.upcoming;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 2, right: index == total - 1 ? 0 : 2),
                child: _Pip(state: state),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({required this.state});

  final VcPipState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      VcPipState.done => AppColors.violet,
      VcPipState.current => AppColors.amber,
      VcPipState.upcoming => AppColors.s3,
    };

    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
