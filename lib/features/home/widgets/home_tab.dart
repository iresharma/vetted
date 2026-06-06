import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_events_teaser.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_nudge_card.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_shortcuts_row.dart';
import 'package:vetted_club_mobile/features/home/widgets/member_tab_scroll.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/trust/providers/trust_report_provider.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key, required this.onNavigate});

  final ValueChanged<VcNavTab> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(profileDraftProvider).value;
    final status = ref.watch(registrationStatusProvider).value;
    final trust = ref.watch(trustReportProvider(null)).value;

    final city = draft?.values['city']?.toString();
    final isLive = draft?.isLive ?? status?.isProfileComplete ?? false;
    final isVerified = status?.isIdentityVerified ?? false;

    HomeNudgeKind? nudge;
    VcNavTab? nudgeTab;
    if (!isVerified) {
      nudge = HomeNudgeKind.verifyIdentity;
      nudgeTab = VcNavTab.profile;
    } else if (!isLive) {
      nudge = HomeNudgeKind.completeProfile;
      nudgeTab = VcNavTab.profile;
    }

    return MemberTabScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeEventsTeaser(city: city),
          const SizedBox(height: AppSpacing.xl),
          const MemberTabSectionLabel(label: 'Shortcuts'),
          const SizedBox(height: AppSpacing.sm),
          HomeShortcutsRow(
            onNavigate: onNavigate,
            trustScore: trust?.trustScore ?? draft?.trustScore ?? status?.trustScore,
            trustTier: trust?.trustTier ?? draft?.trustTier ?? status?.trustTier,
          ),
          if (nudge != null && nudgeTab != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const MemberTabSectionLabel(label: 'Next step'),
            const SizedBox(height: AppSpacing.sm),
            HomeNudgeCard(
              kind: nudge,
              onTap: () => onNavigate(nudgeTab!),
            ),
          ],
        ],
      ),
    );
  }
}
