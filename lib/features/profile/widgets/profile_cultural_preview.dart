import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Live preview + step context for the cultural micro-flow.
class ProfileCulturalPreview extends StatelessWidget {
  const ProfileCulturalPreview({
    super.key,
    this.faith,
    this.motherTongue,
    this.familyStructure,
    this.familyInvolvement,
    this.diet,
    this.marriageTimeline,
    this.microStep = 0,
    this.sectionProgress,
  });

  final String? faith;
  final String? motherTongue;
  final String? familyStructure;
  final String? familyInvolvement;
  final String? diet;
  final String? marriageTimeline;
  final int microStep;
  final double? sectionProgress;

  static const stepLabels = ['Faith', 'Family', 'Life', 'Future'];

  static const _questions = [
    'What roots\ndo you come from?',
    "Who's in\nyour corner?",
    'How do you\nactually live?',
    'What are you\nlooking for?',
  ];

  static const _hints = [
    'Faith and mother tongue — the basics families usually ask about first.',
    'How your family shows up in this process — no wrong answers.',
    'Diet and habits — honest beats ideal every time.',
    'Timeline and intent — plus optional horoscope details if they matter to you.',
  ];

  @override
  Widget build(BuildContext context) {
    final step = microStep.clamp(0, stepLabels.length - 1);
    final previewLine = _previewLine();
    final progress = sectionProgress ?? _progress();

    return VcSoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepProgress(current: step),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.coralDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _stepIcon(step),
                  size: 20,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step + 1} · ${stepLabels[step]}',
                      style: AppTypography.eyebrow(color: AppColors.coral),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _questions[step],
                      style: AppTypography.display().copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTypography.chip(color: AppColors.coral),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _hints[step],
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (_hasContent) ...[
            const SizedBox(height: 16),
            Container(height: 0.5, color: AppColors.border),
            const SizedBox(height: 14),
            Text(
              'How it reads on your profile',
              style: AppTypography.supporting(color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              previewLine,
              style: AppTypography.body().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (faith != null && faith!.isNotEmpty)
                  _Tag(label: faith!, color: AppColors.coral),
                if (motherTongue != null && motherTongue!.isNotEmpty)
                  _Tag(label: motherTongue!, color: AppColors.violet),
                if (familyStructure != null && familyStructure!.isNotEmpty)
                  _Tag(label: familyStructure!, color: AppColors.amber),
                if (diet != null && diet!.isNotEmpty)
                  _Tag(label: diet!, color: AppColors.mint),
                if (marriageTimeline != null && marriageTimeline!.isNotEmpty)
                  _Tag(label: _shortTimeline(marriageTimeline!), color: AppColors.coral),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _stepIcon(int step) => switch (step) {
        0 => PhosphorIconsRegular.handsPraying,
        1 => PhosphorIconsRegular.usersThree,
        2 => PhosphorIconsRegular.forkKnife,
        _ => PhosphorIconsRegular.heart,
      };

  bool get _hasContent =>
      (faith?.isNotEmpty ?? false) ||
      (motherTongue?.isNotEmpty ?? false) ||
      (familyStructure?.isNotEmpty ?? false) ||
      (diet?.isNotEmpty ?? false) ||
      (marriageTimeline?.isNotEmpty ?? false);

  double _progress() {
    var score = 0.0;
    if (faith?.isNotEmpty ?? false) score += 0.2;
    if (motherTongue?.isNotEmpty ?? false) score += 0.15;
    if (familyStructure?.isNotEmpty ?? false) score += 0.15;
    if (familyInvolvement?.isNotEmpty ?? false) score += 0.1;
    if (diet?.isNotEmpty ?? false) score += 0.15;
    if (marriageTimeline?.isNotEmpty ?? false) score += 0.15;
    if (microStep >= 3) score += 0.1;
    return score.clamp(0, 1);
  }

  String _previewLine() {
    if (marriageTimeline?.isNotEmpty ?? false) {
      return 'Looking to marry ${_shortTimeline(marriageTimeline!).toLowerCase()}';
    }
    if (familyStructure?.isNotEmpty ?? false) {
      return '$familyStructure family · $familyInvolvement';
    }
    if (faith?.isNotEmpty ?? false) {
      if (motherTongue?.isNotEmpty ?? false) {
        return '$faith · speaks $motherTongue';
      }
      return faith!;
    }
    if (diet?.isNotEmpty ?? false) {
      return diet!;
    }
    return '';
  }

  static String _shortTimeline(String value) {
    if (value.startsWith('Within')) return value;
    if (value.startsWith('1 to')) return '1–2 years';
    if (value.startsWith('2 to')) return '2–3 years';
    if (value.startsWith('Still')) return 'exploring';
    return value;
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(ProfileCulturalPreview.stepLabels.length, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: active || done ? AppColors.coral : AppColors.s3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ProfileCulturalPreview.stepLabels[i],
                  style: AppTypography.supporting(
                    color: active ? AppColors.coral : AppColors.textMuted,
                  ).copyWith(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.r20,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.supporting(color: color).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
