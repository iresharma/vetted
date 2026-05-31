import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_chip.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_trust_badge.dart';
import 'package:vetted_club_mobile/core/widgets/molecules/vc_soft_card.dart';

class VcProfileCard extends StatelessWidget {
  const VcProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.subtitle,
    required this.prompts,
    this.tags = const [],
    this.trustLabel = 'Highly Trusted',
    this.imageUrl,
  });

  final String name;
  final int age;
  final String subtitle;
  final List<({String question, String answer})> prompts;
  final List<String> tags;
  final String trustLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
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
            _PhotoHero(
              name: name,
              age: age,
              trustLabel: trustLabel,
              imageUrl: imageUrl,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: AppTypography.supporting()),
                  const SizedBox(height: AppSpacing.md),
                  for (final prompt in prompts) ...[
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
                        for (final tag in tags)
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

class _PhotoHero extends StatelessWidget {
  const _PhotoHero({
    required this.name,
    required this.age,
    required this.trustLabel,
    this.imageUrl,
  });

  final String name;
  final int age;
  final String trustLabel;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: imageUrl != null
              ? Image.network(imageUrl!, fit: BoxFit.cover)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.s3,
                        AppColors.s4,
                        AppColors.violet.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.characters.first.toUpperCase(),
                      style: AppTypography.display(color: AppColors.s4),
                    ),
                  ),
                ),
        ),
        Positioned(
          left: AppSpacing.md,
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$name, $age',
                  style: AppTypography.title(),
                ),
              ),
              VcTrustBadge(label: trustLabel),
            ],
          ),
        ),
      ],
    );
  }
}
