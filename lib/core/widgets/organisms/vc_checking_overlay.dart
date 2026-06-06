import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class VcCheckingOverlay extends StatelessWidget {
  const VcCheckingOverlay({
    super.key,
    required this.message,
    this.visible = true,
  });

  final String message;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppMotion.slideDuration,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s2,
          borderRadius: AppRadius.r20,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: VcLoadingIndicator(
            logoSize: 52,
            message: message,
            withGlow: false,
          ),
        ),
      ),
    );
  }
}
