import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/member_tab_scroll.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_report.dart';
import 'package:vetted_club_mobile/features/trust/providers/trust_report_provider.dart';
import 'package:vetted_club_mobile/features/trust/screens/trust_breakdown_screens.dart';
import 'package:vetted_club_mobile/features/trust/widgets/trust_bucket_card.dart';

class TrustReportScreen extends ConsumerStatefulWidget {
  const TrustReportScreen({super.key, this.showBackButton = false, this.user});

  final bool showBackButton;
  final User? user;

  @override
  ConsumerState<TrustReportScreen> createState() => _TrustReportScreenState();
}

class _TrustReportScreenState extends ConsumerState<TrustReportScreen> {
  String? _filter;

  Future<void> _refresh() async {
    await ref.read(trustReportProvider(_filter).notifier).refresh();
  }

  void _setFilter(String? category) {
    if (_filter == category) return;
    setState(() => _filter = category);
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (!widget.showBackButton) return body;

    final report = ref.watch(trustReportProvider(_filter)).value;

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
              eyebrow: 'Your trust',
              title: 'Trust report',
              subtitle: report?.headline,
              trailing: report == null
                  ? null
                  : VcTrustBadge.trustTier(report.trustTier),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final reportAsync = ref.watch(trustReportProvider(_filter));

    return reportAsync.when(
      loading: () => const Center(child: VcLoadingIndicator(logoSize: 56)),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load your trust report.',
                style: AppTypography.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              VcButton(label: 'Try again', onTap: _refresh),
            ],
          ),
        ),
      ),
      data: (report) => _TrustReportContent(
        report: report,
        user: widget.user,
        filter: _filter,
        onFilter: _setFilter,
        onRefresh: _refresh,
        isVerified:
            ref.watch(registrationStatusProvider).value?.isIdentityVerified ??
                false,
      ),
    );
  }
}

class _TrustReportContent extends StatelessWidget {
  const _TrustReportContent({
    required this.report,
    required this.user,
    required this.filter,
    required this.onFilter,
    required this.onRefresh,
    required this.isVerified,
  });

  final TrustReport report;
  final User? user;
  final String? filter;
  final ValueChanged<String?> onFilter;
  final Future<void> Function() onRefresh;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return MemberTabScroll(
      onRefresh: onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: VcTrustGauge(
              score: report.trustScore,
              maxScore: report.trustScoreMax,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Updated ${_formatDate(report.updatedAt.toLocal())}',
            textAlign: TextAlign.center,
            style: AppTypography.microLabel(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: TrustBucketCard(
                  label: 'Profile',
                  value: report.profilePoints,
                  max: report.profilePointsMax,
                  accent: AppColors.violet,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfileTrustBreakdownScreen(
                        report: report,
                        user: user,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TrustBucketCard(
                  label: 'Behavior',
                  value: report.behaviorPoints,
                  max: report.behaviorPointsMax,
                  accent: AppColors.mint,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BehaviorTrustBreakdownScreen(
                        report: report,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _VerificationCard(isVerified: isVerified),
          const SizedBox(height: AppSpacing.xl),
          _MilestonesCard(report: report),
          const SizedBox(height: AppSpacing.xl),
          const MemberTabSectionLabel(label: 'Activity'),
          const SizedBox(height: AppSpacing.sm),
          _ActivityFilters(filter: filter, onFilter: onFilter),
          const SizedBox(height: AppSpacing.md),
          if (report.events.isEmpty)
            VcSoftCard(
              child: Text(
                'No activity yet. Save biodata, attend events, and match with members to build trust.',
                style: AppTypography.supporting(color: AppColors.textSecondary),
              ),
            )
          else
            ...report.events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ActivityTile(event: event),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.mint : AppColors.amber;

    return VcSoftCard(
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              PhosphorIconsRegular.shieldCheck,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity verification',
                  style: AppTypography.title().copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  isVerified
                      ? 'DigiLocker identity on file'
                      : 'Complete verification to boost trust',
                  style: AppTypography.supporting(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          VcTrustBadge.verification(isVerified: isVerified),
        ],
      ),
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.report});

  final TrustReport report;

  int get _unlocked {
    var count = 0;
    if (report.profilePoints >= 100) count++;
    if (report.profilePoints >= 150) count++;
    if (report.behaviorPoints >= 25) count++;
    if (report.behaviorPoints >= 50) count++;
    if (report.trustScore >= 150) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.violetDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              PhosphorIconsRegular.medal,
              color: AppColors.violet,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milestones',
                  style: AppTypography.labelCaps(color: AppColors.violet),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$_unlocked unlocked',
                  style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretRight,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _ActivityFilters extends StatelessWidget {
  const _ActivityFilters({
    required this.filter,
    required this.onFilter,
  });

  final String? filter;
  final ValueChanged<String?> onFilter;

  static const _options = [
    (null, 'All'),
    ('profile', 'Profile'),
    ('behavior', 'Behavior'),
    ('penalty', 'Penalties'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (value, label) in _options) ...[
            VcSelectionPill(
              label: label,
              selected: filter == value,
              onTap: () => onFilter(value),
            ),
            if (value != 'penalty') const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event});

  final TrustScoreEvent event;

  String get _deltaLabel {
    final d = event.deltaTotal;
    if (d == 0) return '—';
    return d > 0 ? '+$d' : '$d';
  }

  Color get _deltaColor {
    if (event.deltaTotal > 0) return AppColors.mint;
    if (event.deltaTotal < 0) return AppColors.coral;
    return AppColors.textMuted;
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(event.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatDate(event.createdAt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              _deltaLabel,
              style: AppTypography.headerCount(color: _deltaColor)
                  .copyWith(fontSize: 16),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.body().copyWith(fontWeight: FontWeight.w600),
                ),
                if (event.body != null && event.body!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    event.body!,
                    style: AppTypography.supporting(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _timeAgo,
                  style: AppTypography.microLabel(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
