import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Live preview card that fills as the user picks interests & rhythm.
class ProfileVibePreview extends StatelessWidget {
  const ProfileVibePreview({
    super.key,
    required this.interests,
    required this.weekendVibes,
    this.microStep = 0,
    this.sectionProgress,
  });

  final List<String> interests;
  final List<String> weekendVibes;
  final int microStep;
  final double? sectionProgress;

  @override
  Widget build(BuildContext context) {
    final hasContent = interests.isNotEmpty || weekendVibes.isNotEmpty;
    final tagline = _tagline();
    final progress = sectionProgress ?? _progress();

    return VcSoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.mintDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIconsRegular.sparkle,
                  size: 18,
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your vibe',
                      style: AppTypography.eyebrow(color: AppColors.mint),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tagline,
                      style: AppTypography.body().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          if (hasContent) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final vibe in weekendVibes.take(2))
                  _VibeChip(label: _shortWeekend(vibe), accent: AppColors.mint),
                for (final interest in interests.take(4))
                  _VibeChip(label: interest, accent: AppColors.violet),
                if (interests.length > 4)
                  _VibeChip(
                    label: '+${interests.length - 4}',
                    accent: AppColors.textSecondary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _progress() {
    var score = 0.0;
    if (interests.length >= 3) {
      score += 0.5;
    } else if (interests.isNotEmpty) {
      score += interests.length / 6;
    }
    if (weekendVibes.isNotEmpty) score += 0.35;
    if (microStep >= 2) score += 0.15;
    return score.clamp(0, 1);
  }

  String _tagline() {
    if (weekendVibes.isNotEmpty) {
      return _shortWeekend(weekendVibes.first);
    }
    if (interests.length >= 3) {
      return '${interests.take(2).join(' · ')} & more';
    }
    if (interests.isNotEmpty) {
      return 'Pick ${3 - interests.length} more to unlock your vibe';
    }
    return 'Start with what you love doing';
  }

  static String _shortWeekend(String full) {
    final dash = full.indexOf('—');
    if (dash > 0) return full.substring(0, dash).trim();
    return full.split(' ').first;
  }
}

class _VibeChip extends StatelessWidget {
  const _VibeChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.r20,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.supporting(color: accent).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
