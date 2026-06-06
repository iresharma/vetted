import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/member_tab_scroll.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/profile_edit_launcher.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_complete_backdrop.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_membership_card_reveal.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_membership_card.dart';

/// Profile tab — membership card, biodata, and account.
class MemberProfileTab extends ConsumerWidget {
  const MemberProfileTab({
    super.key,
    required this.user,
    required this.signingOut,
    required this.onSignOut,
  });

  final User user;
  final bool signingOut;
  final VoidCallback onSignOut;

  String get _memberId {
    final uid = user.uid;
    if (uid.length < 8) return uid.toUpperCase();
    return 'VC-${uid.substring(0, 4).toUpperCase()}';
  }

  String _displayPhone() {
    final phone = user.phoneNumber;
    if (phone == null || phone.length < 4) return 'Member';
    if (phone.length <= 8) return phone;
    return '${phone.substring(0, phone.length - 6)}****${phone.substring(phone.length - 2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftAsync = ref.watch(profileDraftProvider);
    final status = ref.watch(registrationStatusProvider).value;
    final isLive = draftAsync.value?.isLive ?? status?.isProfileComplete ?? false;

    return draftAsync.when(
      loading: () => const Center(child: VcLoadingIndicator(logoSize: 56)),
      error: (_, __) => MemberTabScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VcSoftCard(
              child: Text(
                'Could not load your profile. Pull to refresh or try again later.',
                style: AppTypography.supporting(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AccountSection(
              phone: _displayPhone(),
              signingOut: signingOut,
              onSignOut: onSignOut,
            ),
          ],
        ),
      ),
      data: (draft) => MemberTabScroll(
        onRefresh: () =>
            ref.read(profileDraftProvider.notifier).reload(mergeWithLocal: false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MembershipCardHero(
              draft: draft ?? ProfileDraft(),
              memberId: _memberId,
            ),
            const SizedBox(height: AppSpacing.xl),
            const MemberTabSectionLabel(label: 'Biodata'),
            const SizedBox(height: AppSpacing.sm),
            _ActionRow(
              icon: PhosphorIconsRegular.userCircle,
              label: 'Edit biodata',
              subtitle: isLive
                  ? 'Update photos, prompts & values'
                  : 'Finish required fields to go live',
              onTap: () => ProfileEditLauncher.open(
                context: context,
                ref: ref,
                user: user,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AccountSection(
              phone: _displayPhone(),
              signingOut: signingOut,
              onSignOut: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _MembershipCardHero extends StatelessWidget {
  const _MembershipCardHero({
    required this.draft,
    required this.memberId,
  });

  final ProfileDraft draft;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / ProfileMembershipCardLayout.aspectRatio;

        return SizedBox(
          height: height + 24,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                height: height + 8,
                child: const ProfileCompleteBackdrop(),
              ),
              SizedBox(
                height: height,
                width: width,
                child: VcMembershipCard(
                  draft: draft,
                  memberId: memberId,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r16,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r16,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.s3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.title().copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.supporting(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.phone,
    required this.signingOut,
    required this.onSignOut,
  });

  final String phone;
  final bool signingOut;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MemberTabSectionLabel(label: 'Account'),
        const SizedBox(height: AppSpacing.sm),
        VcSoftCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.deviceMobile,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phone, style: AppTypography.body()),
                    const SizedBox(height: 2),
                    Text(
                      'Phone verified',
                      style: AppTypography.supporting(color: AppColors.mint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: signingOut ? null : onSignOut,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(
            signingOut ? 'Signing out…' : 'Sign out',
            style: AppTypography.button(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
