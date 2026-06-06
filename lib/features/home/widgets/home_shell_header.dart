import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/trust/providers/trust_report_provider.dart';

/// Fixed header for the signed-in home shell — updates with the active tab.
class HomeShellHeader extends ConsumerWidget {
  const HomeShellHeader({
    super.key,
    required this.tab,
    required this.user,
  });

  final VcNavTab tab;
  final User user;

  String get _memberId {
    final uid = user.uid;
    if (uid.length < 8) return uid.toUpperCase();
    return 'VC-${uid.substring(0, 4).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VcPageHeader(
      eyebrow: _eyebrow(tab),
      title: _title(tab, ref),
      subtitle: _subtitle(tab, ref),
      trailing: _trailing(tab, ref),
    );
  }

  String _eyebrow(VcNavTab tab) => switch (tab) {
        VcNavTab.home => 'Home',
        VcNavTab.chat => 'Messages',
        VcNavTab.daily5 => 'Daily 5',
        VcNavTab.trust => 'Your trust',
        VcNavTab.profile => 'Your profile',
      };

  String _title(VcNavTab tab, WidgetRef ref) => switch (tab) {
        VcNavTab.home => _homeGreeting(ref),
        VcNavTab.chat => 'Chats',
        VcNavTab.daily5 => 'Daily picks',
        VcNavTab.trust => 'Trust report',
        VcNavTab.profile => profileFirstName(ref.watch(profileDraftProvider).value),
      };

  String? _subtitle(VcNavTab tab, WidgetRef ref) => switch (tab) {
        VcNavTab.home => _homeSubtitle(ref),
        VcNavTab.chat => 'Conversations with your matches',
        VcNavTab.daily5 => 'Your picks arrive each morning',
        VcNavTab.trust => ref.watch(trustReportProvider(null)).value?.headline,
        VcNavTab.profile => _memberId,
      };

  Widget? _trailing(VcNavTab tab, WidgetRef ref) => switch (tab) {
        VcNavTab.trust => _trustBadge(ref),
        VcNavTab.profile => _liveBadge(ref),
        _ => null,
      };

  Widget? _trustBadge(WidgetRef ref) {
    final tier = ref.watch(trustReportProvider(null)).value?.trustTier;
    if (tier == null) return null;
    return VcTrustBadge.trustTier(tier);
  }

  Widget _liveBadge(WidgetRef ref) {
    final draft = ref.watch(profileDraftProvider).value;
    final status = ref.watch(registrationStatusProvider).value;
    final isLive = draft?.isLive ?? status?.isProfileComplete ?? false;
    return VcTrustBadge.live(isLive: isLive);
  }

  String _homeGreeting(WidgetRef ref) {
    final firstName = profileFirstName(ref.watch(profileDraftProvider).value);
    return '${timeGreeting()}, $firstName';
  }

  String? _homeSubtitle(WidgetRef ref) {
    final city = ref.watch(profileDraftProvider).value?.values['city']?.toString().trim();
    if (city != null && city.isNotEmpty) return city;
    return 'Your member dashboard';
  }

  static String timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String profileFirstName(ProfileDraft? draft) => draft?.firstName ?? 'Member';
}
