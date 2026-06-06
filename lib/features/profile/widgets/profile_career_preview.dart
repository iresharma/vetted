import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Live preview + step context for the career micro-flow.
class ProfileCareerPreview extends StatelessWidget {
  const ProfileCareerPreview({
    super.key,
    this.education,
    this.college,
    this.fieldOfWork,
    this.jobTitle,
    this.company,
    this.microStep = 0,
    this.sectionProgress,
  });

  final String? education;
  final String? college;
  final String? fieldOfWork;
  final String? jobTitle;
  final String? company;
  final int microStep;
  final double? sectionProgress;

  static const _stepLabels = ['Study', 'Work', 'Extra'];

  static const _questions = [
    'Where did your\ncuriosity take you?',
    'What keeps you\nbusy on weekdays?',
    'Anything else\nworth sharing?',
  ];

  static const _hints = [
    'Pick your highest degree — college is a bonus, not a ranking.',
    'Industry and role is enough. Details can wait.',
    'Company, work style, income — all optional, all private until you match.',
  ];

  @override
  Widget build(BuildContext context) {
    final step = microStep.clamp(0, _stepLabels.length - 1);
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
                  color: AppColors.amberDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _stepIcon(step),
                  size: 20,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step + 1} · ${_stepLabels[step]}',
                      style: AppTypography.eyebrow(color: AppColors.amber),
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
                style: AppTypography.chip(color: AppColors.amber),
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
                if (education != null && education!.isNotEmpty)
                  _Tag(label: education!, color: AppColors.amber),
                if (college != null && college!.isNotEmpty)
                  _Tag(label: college!, color: AppColors.amber),
                if (fieldOfWork != null && fieldOfWork!.isNotEmpty)
                  _Tag(label: fieldOfWork!, color: AppColors.violet),
                if (jobTitle != null && jobTitle!.isNotEmpty)
                  _Tag(label: jobTitle!, color: AppColors.mint),
                if (company != null && company!.isNotEmpty)
                  _Tag(label: company!, color: AppColors.coral),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _stepIcon(int step) => switch (step) {
        0 => PhosphorIconsRegular.graduationCap,
        1 => PhosphorIconsRegular.briefcase,
        _ => PhosphorIconsRegular.slidersHorizontal,
      };

  bool get _hasContent =>
      (education?.isNotEmpty ?? false) ||
      (college?.isNotEmpty ?? false) ||
      (fieldOfWork?.isNotEmpty ?? false) ||
      (jobTitle?.isNotEmpty ?? false) ||
      (company?.isNotEmpty ?? false);

  double _progress() {
    var score = 0.0;
    if (education?.isNotEmpty ?? false) score += 0.35;
    if (fieldOfWork?.isNotEmpty ?? false) score += 0.35;
    if (jobTitle?.isNotEmpty ?? false) score += 0.2;
    if (microStep >= 2) score += 0.1;
    return score.clamp(0, 1);
  }

  String _previewLine() {
    if (jobTitle?.isNotEmpty ?? false) {
      final org = company?.trim();
      if (org != null && org.isNotEmpty) {
        return '$jobTitle · $org';
      }
      return jobTitle!;
    }
    if (fieldOfWork?.isNotEmpty ?? false) {
      return fieldOfWork!;
    }
    if (education?.isNotEmpty ?? false) {
      if (college?.isNotEmpty ?? false) {
        return '$education · $college';
      }
      return education!;
    }
    return '';
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(ProfileCareerPreview._stepLabels.length, (i) {
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
                    color: active || done ? AppColors.amber : AppColors.s3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ProfileCareerPreview._stepLabels[i],
                  style: AppTypography.supporting(
                    color: active ? AppColors.amber : AppColors.textMuted,
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
