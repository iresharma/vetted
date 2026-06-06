import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Optional MBTI picker with explainer on what it means and how to discover yours.
class ProfileMbtiSection extends StatelessWidget {
  const ProfileMbtiSection({
    super.key,
    required this.selected,
    required this.onChanged,
    this.accent = AccentColor.mint,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;
  final AccentColor accent;

  static const _types = [
    'INTJ',
    'INTP',
    'ENTJ',
    'ENTP',
    'INFJ',
    'INFP',
    'ENFJ',
    'ENFP',
    'ISTJ',
    'ISFJ',
    'ESTJ',
    'ESFJ',
    'ISTP',
    'ISFP',
    'ESTP',
    'ESFP',
    "Don't know",
  ];

  static const _dimensions = [
    (
      code: 'E / I',
      title: 'Energy',
      body: 'Extraversion — energised by people & action. '
          'Introversion — energised by quiet & reflection.',
    ),
    (
      code: 'S / N',
      title: 'Information',
      body: 'Sensing — focus on facts & what is real today. '
          'Intuition — patterns, ideas & what could be.',
    ),
    (
      code: 'T / F',
      title: 'Decisions',
      body: 'Thinking — logic & consistency first. '
          'Feeling — values & impact on people first.',
    ),
    (
      code: 'J / P',
      title: 'Structure',
      body: 'Judging — plans, closure & schedules. '
          'Perceiving — flexibility & keeping options open.',
    ),
  ];

  Future<void> _openMbtiTest() async {
    final uri = Uri.parse('https://www.16personalities.com/free-personality-test');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        initiallyExpanded: selected != null && selected != "Don't know",
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textMuted,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent.dim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIconsRegular.brain,
                size: 15,
                color: accent.main,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Personality type',
                style: AppTypography.eyebrow(),
              ),
            ),
            if (selected != null && selected != "Don't know")
              Text(
                selected!,
                style: AppTypography.chip(color: accent.main),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 36, top: 4),
          child: Text(
            'Optional · MBTI · 4-letter type',
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
        ),
        children: [
          VcSoftCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What is MBTI?',
                  style: AppTypography.labelCaps().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Myers–Briggs Type Indicator sorts people into 16 types '
                  'using four preferences. Your four-letter code (e.g. INFJ) '
                  'is a snapshot of how you recharge, take in information, '
                  'make decisions, and organise life — not a box, but a '
                  'conversation starter.',
                  style: AppTypography.body(color: AppColors.textSecondary)
                      .copyWith(fontSize: 14, height: 1.55),
                ),
                const SizedBox(height: 16),
                Text(
                  'The four dimensions',
                  style: AppTypography.labelCaps().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                for (final dim in _dimensions) ...[
                  _DimensionRow(
                    code: dim.code,
                    title: dim.title,
                    body: dim.body,
                  ),
                  if (dim != _dimensions.last) const SizedBox(height: 10),
                ],
                const SizedBox(height: 16),
                Text(
                  'How to find yours',
                  style: AppTypography.labelCaps().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Take a short questionnaire (≈10 min)\n'
                  '2. Each question scores you on one axis\n'
                  '3. Your highest score on each pair becomes one letter\n'
                  '4. Combine all four → your type (e.g. ENFP)',
                  style: AppTypography.body(color: AppColors.textSecondary)
                      .copyWith(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _openMbtiTest,
                  icon: Icon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 16,
                    color: accent.main,
                  ),
                  label: Text(
                    'Take free test on 16Personalities',
                    style: AppTypography.supporting(color: accent.main)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Already know your type? Pick it below.',
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in _types)
                GestureDetector(
                  onTap: () => onChanged(selected == type ? null : type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected == type ? accent.dim : AppColors.s2,
                      borderRadius: AppRadius.r12,
                      border: Border.all(
                        color: selected == type ? accent.main : AppColors.border,
                        width: selected == type ? 1.5 : 0.5,
                      ),
                    ),
                    child: Text(
                      type,
                      style: AppTypography.supporting(
                        color: selected == type
                            ? accent.main
                            : AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    required this.code,
    required this.title,
    required this.body,
  });

  final String code;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.s3,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: AppTypography.supporting(color: AppColors.violet).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.supporting().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: AppTypography.supporting(color: AppColors.textMuted)
                    .copyWith(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
