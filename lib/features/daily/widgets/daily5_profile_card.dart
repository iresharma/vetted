import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class Daily5MatchReasonBadge extends StatelessWidget {
  const Daily5MatchReasonBadge({
    super.key,
    required this.label,
    this.fieldId,
  });

  final String label;
  final String? fieldId;

  IconData get _icon => switch (fieldId) {
        'marriage_timeline' => PhosphorIconsRegular.calendarHeart,
        'diet' || 'drinking' || 'smoking' => PhosphorIconsRegular.leaf,
        'faith' => PhosphorIconsRegular.handsPraying,
        'city' || 'home_state' || 'willing_to_relocate' => PhosphorIconsRegular.mapPin,
        'family_involvement' || 'family_structure' => PhosphorIconsRegular.users,
        'wants_children' => PhosphorIconsRegular.baby,
        _ => PhosphorIconsRegular.sparkle,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: AppColors.violet),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Matched on: $label',
              style: AppTypography.chip(color: AppColors.violet),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Daily5ProfileCard extends StatelessWidget {
  const Daily5ProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.subtitle,
    required this.prompts,
    required this.compatibilityScore,
    this.matchReasonLabel,
    this.matchReasonField,
    this.tags = const [],
    this.trustTier = 'trusted',
    this.imageUrl,
  });

  final String name;
  final int? age;
  final String subtitle;
  final List<({String question, String answer})> prompts;
  final int compatibilityScore;
  final String? matchReasonLabel;
  final String? matchReasonField;
  final List<String> tags;
  final String trustTier;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final ageLabel = age != null ? ', $age' : '';

    return ClipRRect(
      borderRadius: AppRadius.r20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s2,
          borderRadius: AppRadius.r20,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.s3,
                          child: Icon(
                            PhosphorIconsRegular.user,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                        ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: VcTrustBadge.trustTier(trustTier),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$compatibilityScore% match',
                      style: AppTypography.chip(color: AppColors.amber),
                    ),
                  ),
                ),
                if (matchReasonLabel != null && matchReasonLabel!.isNotEmpty)
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Daily5MatchReasonBadge(
                      label: matchReasonLabel!,
                      fieldId: matchReasonField,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name$ageLabel',
                    style: AppTypography.title(),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.supporting()),
                  const SizedBox(height: AppSpacing.md),
                  for (final prompt in prompts.take(2)) ...[
                    VcSoftCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.question,
                            style: AppTypography.title().copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prompt.answer,
                            style: AppTypography.supporting(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final tag in tags.take(4))
                          VcChip(label: tag, variant: VcChipVariant.muted),
                      ],
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
