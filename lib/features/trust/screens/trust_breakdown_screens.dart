import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/member_tab_scroll.dart';
import 'package:vetted_club_mobile/features/profile/profile_edit_launcher.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_breakdown.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_report.dart';

class ProfileTrustBreakdownScreen extends ConsumerWidget {
  const ProfileTrustBreakdownScreen({
    super.key,
    required this.report,
    this.user,
  });

  final TrustReport report;
  final User? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = report.profileBreakdown;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VcPageHeader(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  PhosphorIconsRegular.caretLeft,
                  color: AppColors.textPrimary,
                ),
              ),
              eyebrow: 'Profile trust',
              title: '${report.profilePoints} / ${report.profilePointsMax}',
              subtitle: breakdown == null
                  ? 'Breakdown unavailable — pull to refresh on trust report'
                  : '${breakdown.max - breakdown.total} pts still available',
            ),
            Expanded(
              child: breakdown == null
                  ? _EmptyBreakdown(
                      message: 'Could not load profile breakdown.',
                    )
                  : ListView(
                      padding: MemberTabScroll.padding,
                      children: [
                        for (final section in breakdown.sections) ...[
                          _SectionHeader(section: section),
                          const SizedBox(height: AppSpacing.sm),
                          if (section.missingItems.isNotEmpty) ...[
                            ...section.missingItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: HomeBentoStyle.gap,
                                ),
                                child: _MissingFieldTile(item: item),
                              ),
                            ),
                          ] else
                            VcBentoCard(
                              accent: AccentColor.mint,
                              child: Text(
                                'All fields in this section are complete.',
                                style: AppTypography.supporting(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        if (user != null)
                          VcButton(
                            label: 'Edit biodata',
                            expanded: true,
                            onTap: () => ProfileEditLauncher.open(
                              context: context,
                              ref: ref,
                              user: user!,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BehaviorTrustBreakdownScreen extends StatelessWidget {
  const BehaviorTrustBreakdownScreen({super.key, required this.report});

  final TrustReport report;

  @override
  Widget build(BuildContext context) {
    final breakdown = report.behaviorBreakdown;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VcPageHeader(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  PhosphorIconsRegular.caretLeft,
                  color: AppColors.textPrimary,
                ),
              ),
              eyebrow: 'Behavior trust',
              title: '${report.behaviorPoints} / ${report.behaviorPointsMax}',
              subtitle: breakdown == null
                  ? 'Breakdown unavailable — pull to refresh on trust report'
                  : '${breakdown.max - breakdown.total} pts still available',
            ),
            Expanded(
              child: breakdown == null
                  ? _EmptyBreakdown(
                      message: 'Could not load behavior breakdown.',
                    )
                  : ListView(
                      padding: MemberTabScroll.padding,
                      children: [
                        VcSoftCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Behavior trust grows as you engage on Vetted — attending events, matching with members, responding promptly, and earning positive feedback.',
                            style: AppTypography.supporting(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        for (final item in breakdown.items) ...[
                          _BehaviorItemTile(item: item),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBreakdown extends StatelessWidget {
  const _EmptyBreakdown({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final TrustBreakdownSection section;

  @override
  Widget build(BuildContext context) {
    final progress = section.pointsMax == 0
        ? 0.0
        : (section.pointsEarned / section.pointsMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.label, style: AppTypography.title().copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          section.description,
          style: AppTypography.supporting(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${formatTrustPoints(section.pointsEarned)} / ${section.pointsMax} pts',
          style: AppTypography.chip(color: AppColors.violet),
        ),
        const SizedBox(height: AppSpacing.sm),
        VcXpBar(progress: progress, height: 4, animateOnMount: false),
      ],
    );
  }
}

class _MissingFieldTile extends StatelessWidget {
  const _MissingFieldTile({required this.item});

  final TrustBreakdownItem item;

  @override
  Widget build(BuildContext context) {
    return VcBentoCard(
      accent: AccentColor.amber,
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.plus,
            size: 22,
            color: AppColors.amber,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTypography.title().copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Missing · +${formatTrustPoints(item.pointsPossible)} pts',
                  style: AppTypography.supporting(color: AppColors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviorItemTile extends StatelessWidget {
  const _BehaviorItemTile({required this.item});

  final TrustBehaviorItem item;

  @override
  Widget build(BuildContext context) {
    final progress =
        item.pointsMax == 0 ? 0.0 : item.pointsEarned / item.pointsMax;
    final isMaxed = item.pointsEarned >= item.pointsMax;

    return VcSoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${item.pointsEarned} / ${item.pointsMax}',
                style: AppTypography.chip(
                  color: isMaxed ? AppColors.mint : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            item.description,
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Current: ${item.currentValue}',
            style: AppTypography.supporting(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          VcXpBar(progress: progress.clamp(0.0, 1.0), height: 4, animateOnMount: false),
        ],
      ),
    );
  }
}
