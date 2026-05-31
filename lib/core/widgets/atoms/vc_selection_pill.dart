import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcSelectionPillVariant { default_, violet, amber }

class VcSelectionPill extends StatelessWidget {
  const VcSelectionPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.variant = VcSelectionPillVariant.default_,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VcSelectionPillVariant variant;

  @override
  Widget build(BuildContext context) {
    final activeVariant = variant == VcSelectionPillVariant.default_
        ? VcSelectionPillVariant.violet
        : variant;

    final colors = selected
        ? switch (activeVariant) {
            VcSelectionPillVariant.violet => (
                bg: AppColors.violetDim,
                border: AppColors.violet,
                text: AppColors.violet,
              ),
            VcSelectionPillVariant.amber => (
                bg: AppColors.amberDim,
                border: AppColors.amber,
                text: AppColors.amber,
              ),
            VcSelectionPillVariant.default_ => (
                bg: AppColors.violetDim,
                border: AppColors.violet,
                text: AppColors.violet,
              ),
          }
        : (
            bg: AppColors.s2,
            border: AppColors.border,
            text: AppColors.textSecondary,
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: AppRadius.r20,
          border: Border.all(
            color: colors.border,
            width: selected ? 1 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.supporting(color: colors.text).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class VcSelectionPillGroup extends StatelessWidget {
  const VcSelectionPillGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.variant = VcSelectionPillVariant.default_,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  final VcSelectionPillVariant variant;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in options)
          VcSelectionPill(
            label: option,
            selected: option == selected,
            variant: variant,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}
