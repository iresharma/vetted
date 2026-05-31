import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcChipVariant { violet, amber, coral, mint, muted }

class VcChip extends StatelessWidget {
  const VcChip({
    super.key,
    required this.label,
    this.variant = VcChipVariant.violet,
    this.showDot = false,
  });

  final String label;
  final VcChipVariant variant;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForVariant(variant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.r6,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colors.foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTypography.chip(color: colors.foreground)),
        ],
      ),
    );
  }

  _ChipColors _colorsForVariant(VcChipVariant variant) {
    return switch (variant) {
      VcChipVariant.violet => const _ChipColors(
          background: AppColors.violetDim,
          border: AppColors.violet,
          foreground: AppColors.violet,
        ),
      VcChipVariant.amber => const _ChipColors(
          background: AppColors.amberDim,
          border: AppColors.amber,
          foreground: AppColors.amber,
        ),
      VcChipVariant.coral => const _ChipColors(
          background: AppColors.coralDim,
          border: AppColors.coral,
          foreground: AppColors.coral,
        ),
      VcChipVariant.mint => const _ChipColors(
          background: AppColors.mintDim,
          border: AppColors.mint,
          foreground: AppColors.mint,
        ),
      VcChipVariant.muted => const _ChipColors(
          background: AppColors.s3,
          border: AppColors.border,
          foreground: AppColors.textSecondary,
        ),
    };
  }
}

class _ChipColors {
  const _ChipColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;
}
