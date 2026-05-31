import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/neopop/neopop_pressable.dart';

class VcNeoPopCard extends StatelessWidget {
  const VcNeoPopCard({
    super.key,
    required this.child,
    this.accent = AccentColor.violet,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final AccentColor accent;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: AppRadius.r12,
        border: Border.all(color: accent.main, width: 1),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.dark,
                  borderRadius: AppRadius.r12,
                ),
                child: Opacity(opacity: 0, child: content),
              ),
            ),
            content,
          ],
        ),
      );
    }

    return NeoPopPressable(
      onTap: onTap,
      shadowColor: accent.dark,
      borderRadius: AppRadius.r12,
      child: content,
    );
  }
}
