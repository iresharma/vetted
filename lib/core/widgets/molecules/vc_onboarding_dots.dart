import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Small dot progress indicator used in onboarding screens.
class VcOnboardingDots extends StatelessWidget {
  const VcOnboardingDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        final isDone = index < currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: AppMotion.standardCurve,
          margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
          width: isActive ? 20 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: (isActive || isDone ? AppColors.violet : AppColors.s3)
                .withValues(alpha: isDone && !isActive ? 0.4 : 1),
            borderRadius: BorderRadius.circular(isActive ? 3 : 2.5),
          ),
        );
      }),
    );
  }
}
