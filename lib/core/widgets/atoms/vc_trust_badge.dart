import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcTrustBadgeVariant { violet, mint, amber }

class VcTrustBadge extends StatelessWidget {
  const VcTrustBadge({
    super.key,
    required this.label,
    this.variant = VcTrustBadgeVariant.mint,
  });

  final String label;
  final VcTrustBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      VcTrustBadgeVariant.violet => (
          bg: AppColors.violetDim,
          border: AppColors.violet,
          dot: AppColors.violet,
          text: AppColors.violet,
        ),
      VcTrustBadgeVariant.mint => (
          bg: AppColors.mintDim,
          border: AppColors.mint,
          dot: AppColors.mint,
          text: AppColors.mint,
        ),
      VcTrustBadgeVariant.amber => (
          bg: AppColors.amberDim,
          border: AppColors.amber,
          dot: AppColors.amber,
          text: AppColors.amber,
        ),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: AppRadius.r6,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colors.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.chip(color: colors.text)),
        ],
      ),
    );
  }
}
