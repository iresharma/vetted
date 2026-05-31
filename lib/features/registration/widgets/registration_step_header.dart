import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Step indicator for the 2-gate registration flow (membership → DigiLocker).
class RegistrationStepHeader extends StatelessWidget {
  const RegistrationStepHeader({
    super.key,
    required this.stepIndex,
    this.totalSteps = 2,
  });

  /// Zero-based index of the current step.
  final int stepIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = (stepIndex + 1) / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${stepIndex + 1} of $totalSteps',
                style: AppTypography.eyebrow(color: AppColors.violet),
              ),
              Row(
                children: List.generate(totalSteps, (index) {
                  final filled = index <= stepIndex;
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                    child: Container(
                      width: 22,
                      height: 3,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.violet : AppColors.s3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.s3),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0, 1),
                    child: Container(color: AppColors.violet),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
