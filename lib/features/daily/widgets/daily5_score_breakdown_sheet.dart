import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';

class Daily5ScoreBreakdownSheet extends StatelessWidget {
  const Daily5ScoreBreakdownSheet({
    super.key,
    required this.compatibilityScore,
    required this.scoreBreakdown,
    required this.displayName,
    this.age,
    this.matchReasonLabel,
    this.matchReasonField,
    this.onSendInterest,
  });

  final int compatibilityScore;
  final Map<String, dynamic> scoreBreakdown;
  final String displayName;
  final int? age;
  final String? matchReasonLabel;
  final String? matchReasonField;
  final VoidCallback? onSendInterest;

  static Future<void> show(
    BuildContext context, {
    required int compatibilityScore,
    required Map<String, dynamic> scoreBreakdown,
    required String displayName,
    int? age,
    String? matchReasonLabel,
    String? matchReasonField,
    VoidCallback? onSendInterest,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Daily5ScoreBreakdownSheet(
        compatibilityScore: compatibilityScore,
        scoreBreakdown: scoreBreakdown,
        displayName: displayName,
        age: age,
        matchReasonLabel: matchReasonLabel,
        matchReasonField: matchReasonField,
        onSendInterest: onSendInterest == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                onSendInterest();
              },
      ),
    );
  }

  List<({String fieldId, int score})> get _sortedItems {
    final items = <({String fieldId, int score})>[];
    for (final entry in scoreBreakdown.entries) {
      if (entry.key.startsWith('_')) continue;
      final score = entry.value;
      if (score is! num) continue;
      items.add((fieldId: entry.key, score: score.round()));
    }
    items.sort((a, b) => b.score.compareTo(a.score));
    return items;
  }

  int? _metaInt(String key) {
    final value = scoreBreakdown[key];
    if (value is num) return value.round();
    return null;
  }

  /// Footnote when the card score differs from the weighted value base
  /// (trust/recency) or from dev queue spread.
  String? get _scoreFootnote {
    final computed = _metaInt('_computedOverall');
    final raw = _metaInt('_rawScore');
    final trust = _metaInt('_trustBonus');
    final recency = _metaInt('_recencyPenalty');

    if (computed != null && computed != compatibilityScore) {
      return 'Computed match $computed%. Card shows $compatibilityScore% '
          'because legacy dev score spread is enabled.';
    }

    final parts = <String>[];
    if (trust != null && trust > 0) parts.add('+$trust profile trust');
    if (recency != null && recency > 0) {
      parts.add('−$recency repeat exposure');
    }
    if (parts.isEmpty) return null;

    final base = raw ?? computed;
    if (base != null && base != compatibilityScore) {
      return 'Weighted value match $base%, adjusted with ${parts.join(' and ')}.';
    }
    return 'Includes ${parts.join(' and ')}.';
  }

  String get _firstName {
    final clean = displayName.replaceFirst(RegExp(r'^\[TEST\]\s*'), '').trim();
    final parts = clean.split(RegExp(r'[\s,]'));
    return parts.isNotEmpty ? parts.first : 'them';
  }

  String get _nameWithAge {
    final ageLabel = age != null ? ', $age' : '';
    return '$displayName$ageLabel';
  }

  @override
  Widget build(BuildContext context) {
    final items = _sortedItems;
    final primary = items.take(4).toList();
    final secondary = items.length > 4 ? items.sublist(4) : const [];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.s3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                children: [
                  Text(
                    'COMPATIBILITY REPORT',
                    style: AppTypography.microLabel(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Score breakdown',
                    style: AppTypography.headline(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _OverallMatchHero(
                    score: compatibilityScore,
                    footnote: _scoreFootnote,
                    nameWithAge: _nameWithAge,
                    matchReasonLabel: matchReasonLabel,
                    matchReasonField: matchReasonField,
                  ),
                  if (primary.isNotEmpty) ...[
                    const SizedBox(height: HomeBentoStyle.gap),
                    Text(
                      'How you align on each value',
                      style: AppTypography.supporting(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall is weighted by what matters most to you — '
                      'not a simple average of the rows below.',
                      style: AppTypography.microLabel(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: HomeBentoStyle.gap,
                        mainAxisSpacing: HomeBentoStyle.gap,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: primary.length,
                      itemBuilder: (_, index) {
                        final item = primary[index];
                        return _PrimaryScoreTile(
                          fieldId: item.fieldId,
                          label: dailyScoreFieldLabel(item.fieldId),
                          score: item.score,
                        );
                      },
                    ),
                  ],
                  if (secondary.isNotEmpty) ...[
                    const SizedBox(height: HomeBentoStyle.gap),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.s2,
                        borderRadius: HomeBentoStyle.borderRadius,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < secondary.length; i++)
                            _SecondaryScoreRow(
                              fieldId: secondary[i].fieldId,
                              label: dailyScoreFieldLabel(secondary[i].fieldId),
                              score: secondary[i].score,
                              showDivider: i < secondary.length - 1,
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Text(
                        'No breakdown available for this pick.',
                        textAlign: TextAlign.center,
                        style: AppTypography.supporting(color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            if (onSendInterest != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: VcButton.muted(
                  label: 'Send interest to $_firstName',
                  expanded: true,
                  icon: PhosphorIconsRegular.heart,
                  iconPosition: VcButtonIconPosition.leading,
                  onTap: onSendInterest,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverallMatchHero extends StatelessWidget {
  const _OverallMatchHero({
    required this.score,
    required this.nameWithAge,
    this.footnote,
    this.matchReasonLabel,
    this.matchReasonField,
  });

  final int score;
  final String? footnote;
  final String nameWithAge;
  final String? matchReasonLabel;
  final String? matchReasonField;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: HomeBentoStyle.borderRadius,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: HomeBentoStyle.tilePadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score',
                    style: AppTypography.display(color: AppColors.amber)
                        .copyWith(fontSize: 56, height: 0.95),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall match',
                    style: AppTypography.labelCaps(color: AppColors.textMuted),
                  ),
                  if (footnote != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      footnote!,
                      style: AppTypography.microLabel(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    nameWithAge,
                    textAlign: TextAlign.right,
                    style: AppTypography.title().copyWith(fontSize: 22),
                  ),
                  if (matchReasonLabel != null && matchReasonLabel!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _MatchReasonPill(
                      label: matchReasonLabel!,
                      fieldId: matchReasonField,
                    ),
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

class _MatchReasonPill extends StatelessWidget {
  const _MatchReasonPill({required this.label, this.fieldId});

  final String label;
  final String? fieldId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amberDim,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _fieldIcon(fieldId),
            size: 14,
            color: AppColors.amber,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.chip(color: AppColors.amber),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryScoreTile extends StatelessWidget {
  const _PrimaryScoreTile({
    required this.fieldId,
    required this.label,
    required this.score,
  });

  final String fieldId;
  final String label;
  final int score;

  Color get _scoreColor => _scoreAccent(score);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: HomeBentoStyle.borderRadius,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.mintDim,
                borderRadius: AppRadius.r8,
              ),
              child: Icon(
                _fieldIcon(fieldId),
                size: 18,
                color: AppColors.mint,
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: AppTypography.labelCaps(color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '$score%',
              style: AppTypography.headline(color: _scoreColor)
                  .copyWith(fontSize: 24, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryScoreRow extends StatelessWidget {
  const _SecondaryScoreRow({
    required this.fieldId,
    required this.label,
    required this.score,
    required this.showDivider,
  });

  final String fieldId;
  final String label;
  final int score;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.s3,
              borderRadius: AppRadius.r8,
            ),
            child: Icon(
              _fieldIcon(fieldId),
              size: 18,
              color: AppColors.amber,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              label,
              style: AppTypography.title().copyWith(fontSize: 15),
            ),
          ),
          Text(
            '$score%',
            style: AppTypography.title(color: _scoreAccent(score))
                .copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

Color _scoreAccent(int score) {
  if (score >= 80) return AppColors.mint;
  if (score >= 50) return AppColors.amber;
  return AppColors.coral;
}

IconData _fieldIcon(String? fieldId) {
  return switch (fieldId) {
    'marriage_timeline' => PhosphorIconsRegular.calendarHeart,
    'diet' || 'drinking' || 'smoking' => PhosphorIconsRegular.leaf,
    'faith' => PhosphorIconsRegular.handsPraying,
    'city' || 'home_state' => PhosphorIconsRegular.mapPin,
    'willing_to_relocate' => PhosphorIconsRegular.airplaneTilt,
    'family_involvement' || 'family_structure' => PhosphorIconsRegular.users,
    'wants_children' => PhosphorIconsRegular.baby,
    'education_level' => PhosphorIconsRegular.graduationCap,
    'field_of_work' || 'work_mode' => PhosphorIconsRegular.briefcase,
    'weekend_vibe' => PhosphorIconsRegular.sparkle,
    'exercise_frequency' => PhosphorIconsRegular.personSimpleRun,
    'pet_preference' => PhosphorIconsRegular.pawPrint,
    'travel_frequency' => PhosphorIconsRegular.airplane,
    _ => PhosphorIconsRegular.chartBar,
  };
}
