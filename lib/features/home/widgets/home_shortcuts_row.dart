import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/domain/trust_tier.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_action_card.dart';

/// Stacked shortcut cards — trust-report style for Daily 5, Trust, and Chats.
class HomeShortcutsRow extends StatelessWidget {
  const HomeShortcutsRow({
    super.key,
    required this.onNavigate,
    this.trustScore,
    this.trustTier,
  });

  final ValueChanged<VcNavTab> onNavigate;
  final int? trustScore;
  final String? trustTier;

  @override
  Widget build(BuildContext context) {
    final trustSubtitle = trustScore != null
        ? '$trustScore · ${TrustTierLabels.label(trustTier)}'
        : 'View your trust report';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeActionCard(
          icon: PhosphorIconsFill.diamond,
          iconColor: AppColors.violet,
          iconBackground: AppColors.violetDim,
          label: 'Daily 5',
          labelColor: AppColors.violet,
          title: 'Your morning picks',
          subtitle: 'Five curated profiles, refreshed daily',
          onTap: () => onNavigate(VcNavTab.daily5),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeActionCard(
          icon: PhosphorIconsRegular.shieldCheck,
          iconColor: AppColors.mint,
          iconBackground: AppColors.mintDim,
          label: 'Trust',
          labelColor: AppColors.mint,
          title: 'Trust report',
          subtitle: trustSubtitle,
          onTap: () => onNavigate(VcNavTab.trust),
        ),
        const SizedBox(height: AppSpacing.sm),
        HomeActionCard(
          icon: PhosphorIconsRegular.chatCircle,
          iconColor: AppColors.coral,
          iconBackground: AppColors.coralDim,
          label: 'Chats',
          labelColor: AppColors.coral,
          title: 'Messages',
          subtitle: 'Conversations with your matches',
          onTap: () => onNavigate(VcNavTab.chat),
        ),
      ],
    );
  }
}
