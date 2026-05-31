import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/neopop/neopop_pressable.dart';

enum VcButtonVariant { violet, coral, amber, ghost, muted }

enum VcButtonSize { large, medium, small }

enum VcButtonIconPosition { leading, trailing }

class VcButton extends StatelessWidget {
  const VcButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = VcButtonVariant.violet,
    this.size = VcButtonSize.medium,
    this.expanded = false,
    this.enabled = true,
    this.icon,
    this.iconPosition = VcButtonIconPosition.trailing,
  });

  const VcButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.size = VcButtonSize.medium,
    this.expanded = false,
    this.enabled = true,
    this.icon,
    this.iconPosition = VcButtonIconPosition.trailing,
  }) : variant = VcButtonVariant.ghost;

  const VcButton.muted({
    super.key,
    required this.label,
    this.onTap,
    this.size = VcButtonSize.medium,
    this.expanded = false,
    this.enabled = true,
    this.icon,
    this.iconPosition = VcButtonIconPosition.trailing,
  }) : variant = VcButtonVariant.muted;

  final String label;
  final VoidCallback? onTap;
  final VcButtonVariant variant;
  final VcButtonSize size;
  final bool expanded;
  final bool enabled;
  final IconData? icon;
  final VcButtonIconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final style = _styleForVariant(variant);
    final height = switch (size) {
      VcButtonSize.large => 56.0,
      VcButtonSize.medium => 48.0,
      VcButtonSize.small => 36.0,
    };
    final radius = size == VcButtonSize.small ? AppRadius.r8 : AppRadius.r12;
    final horizontalPadding = size == VcButtonSize.small ? 16.0 : 24.0;
    final textStyle = size == VcButtonSize.small
        ? AppTypography.buttonSmall(color: style.foreground)
        : AppTypography.button(color: style.foreground);
    final iconSize = size == VcButtonSize.small ? 16.0 : 18.0;

    final labelWidget = Text(
      label,
      style: textStyle,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final content = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: radius,
          border: style.border,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(
            child: icon == null
                ? labelWidget
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconPosition == VcButtonIconPosition.leading) ...[
                        Icon(icon, size: iconSize, color: style.foreground),
                        const SizedBox(width: 8),
                      ],
                      Flexible(child: labelWidget),
                      if (iconPosition == VcButtonIconPosition.trailing) ...[
                        const SizedBox(width: 8),
                        Icon(icon, size: iconSize, color: style.foreground),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    if (variant == VcButtonVariant.muted) {
      return NeoPopPressable(
        enabled: enabled,
        onTap: onTap,
        shadowColor: AppColors.s4,
        borderRadius: radius,
        idleShadowOffset: 3,
        child: content,
      );
    }

    return NeoPopPressable(
      enabled: enabled,
      onTap: onTap,
      shadowColor: style.shadow,
      borderRadius: radius,
      idleShadowOffset: size == VcButtonSize.small ? 2 : 4,
      child: content,
    );
  }

  _ButtonStyle _styleForVariant(VcButtonVariant variant) {
    return switch (variant) {
      VcButtonVariant.violet => const _ButtonStyle(
          background: AppColors.violet,
          shadow: AppColors.violetDark,
          foreground: AppColors.onViolet,
        ),
      VcButtonVariant.coral => const _ButtonStyle(
          background: AppColors.coral,
          shadow: AppColors.coralDark,
          foreground: AppColors.onViolet,
        ),
      VcButtonVariant.amber => const _ButtonStyle(
          background: AppColors.amber,
          shadow: AppColors.amberDark,
          foreground: AppColors.onAmber,
        ),
      VcButtonVariant.ghost => const _ButtonStyle(
          background: Colors.transparent,
          shadow: AppColors.violetDark,
          foreground: AppColors.violet,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.violet, width: 1.5),
          ),
        ),
      VcButtonVariant.muted => const _ButtonStyle(
          background: Colors.transparent,
          shadow: AppColors.s4,
          foreground: AppColors.textSecondary,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
    };
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.shadow,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color shadow;
  final Color foreground;
  final BoxBorder? border;
}

/// Pass + I'm interested row with 2.5× flex ratio per design spec.
class VcActionButtonRow extends StatelessWidget {
  const VcActionButtonRow({
    super.key,
    this.onPass,
    this.onInterested,
  });

  final VoidCallback? onPass;
  final VoidCallback? onInterested;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: VcButton.muted(
            label: 'Pass',
            onTap: onPass,
            expanded: true,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 5,
          child: VcButton(
            label: "I'm interested →",
            variant: VcButtonVariant.coral,
            onTap: onInterested,
            expanded: true,
          ),
        ),
      ],
    );
  }
}
