import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VcCheckingOverlay extends StatefulWidget {
  const VcCheckingOverlay({
    super.key,
    required this.message,
    this.visible = true,
  });

  final String message;
  final bool visible;

  @override
  State<VcCheckingOverlay> createState() => _VcCheckingOverlayState();
}

class _VcCheckingOverlayState extends State<VcCheckingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: widget.visible ? 1 : 0,
      duration: AppMotion.slideDuration,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s2,
          borderRadius: AppRadius.r20,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _spinController,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.s3, width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      height: 6,
                      color: AppColors.violet,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.message,
                style: AppTypography.body(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
