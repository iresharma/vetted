import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/domain/trust_tier.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcTrustBadgeVariant { violet, mint, amber }

/// Unified status pill used across the app (live, trust tier, verification, etc.).
class VcTrustBadge extends StatelessWidget {
  const VcTrustBadge({
    super.key,
    required this.label,
    this.variant = VcTrustBadgeVariant.mint,
    this.icon,
  });

  final String label;
  final VcTrustBadgeVariant variant;
  final IconData? icon;

  factory VcTrustBadge.live({required bool isLive}) {
    return VcTrustBadge(
      label: isLive ? 'Live member' : 'Profile in progress',
      variant: isLive ? VcTrustBadgeVariant.mint : VcTrustBadgeVariant.amber,
      icon: isLive
          ? PhosphorIconsRegular.sealCheck
          : PhosphorIconsRegular.hourglass,
    );
  }

  factory VcTrustBadge.trustTier(String? tier) {
    return VcTrustBadge(
      label: TrustTierLabels.label(tier),
      variant: _variantForTier(tier),
      icon: _iconForTier(tier),
    );
  }

  factory VcTrustBadge.verification({required bool isVerified}) {
    return VcTrustBadge(
      label: isVerified ? 'Verified' : 'Pending',
      variant: isVerified ? VcTrustBadgeVariant.mint : VcTrustBadgeVariant.amber,
      icon: isVerified
          ? PhosphorIconsRegular.shieldCheck
          : PhosphorIconsRegular.shieldWarning,
    );
  }

  static VcTrustBadgeVariant _variantForTier(String? tier) => switch (tier) {
        'elite' => VcTrustBadgeVariant.violet,
        'highly_trusted' => VcTrustBadgeVariant.mint,
        _ => VcTrustBadgeVariant.amber,
      };

  static IconData _iconForTier(String? tier) => switch (tier) {
        'elite' => PhosphorIconsRegular.crown,
        'highly_trusted' => PhosphorIconsRegular.sealCheck,
        _ => PhosphorIconsRegular.shield,
      };

  Color get _color => switch (variant) {
        VcTrustBadgeVariant.violet => AppColors.violet,
        VcTrustBadgeVariant.mint => AppColors.mint,
        VcTrustBadgeVariant.amber => AppColors.amber,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final resolvedIcon = icon ?? switch (variant) {
      VcTrustBadgeVariant.violet => PhosphorIconsRegular.crown,
      VcTrustBadgeVariant.mint => PhosphorIconsRegular.sealCheck,
      VcTrustBadgeVariant.amber => PhosphorIconsRegular.hourglass,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolvedIcon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.chip(color: color)),
        ],
      ),
    );
  }
}
