import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Home bento spacing tokens — used on trust score breakdown lists.
abstract final class HomeBentoStyle {
  static const gap = 6.0;
  static const tilePadding = EdgeInsets.all(AppSpacing.lg);
  static const borderRadius = AppRadius.r16;
}

/// Coloured bento cell — accent-tinted surface matching the home screen bento.
class VcBentoCard extends StatelessWidget {
  const VcBentoCard({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
    this.borderRadius = HomeBentoStyle.borderRadius,
    this.padding = HomeBentoStyle.tilePadding,
  });

  final AccentColor accent;
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: accent.dim,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                splashColor: accent.main.withValues(alpha: 0.08),
                highlightColor: accent.main.withValues(alpha: 0.04),
                child: content,
              ),
      ),
    );
  }
}
