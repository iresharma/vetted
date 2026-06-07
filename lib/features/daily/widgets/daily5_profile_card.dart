import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class Daily5MatchReasonBadge extends StatelessWidget {
  const Daily5MatchReasonBadge({
    super.key,
    required this.label,
    this.fieldId,
    this.onDarkBackground = false,
  });

  final String label;
  final String? fieldId;
  final bool onDarkBackground;

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
    final bgAlpha = onDarkBackground ? 0.22 : 0.12;
    final borderAlpha = onDarkBackground ? 0.45 : 0.35;
    final textColor = onDarkBackground ? AppColors.textPrimary : AppColors.violet;
    final iconColor = onDarkBackground ? AppColors.mint : AppColors.violet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.violet.withValues(alpha: borderAlpha),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Matched on: $label',
              style: AppTypography.chip(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Daily5CompactActionButton extends StatelessWidget {
  const Daily5CompactActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
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
            color: AppColors.s3,
            borderRadius: AppRadius.r16,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: AppColors.violet),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.title().copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
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
    this.interestedInYou = false,
    this.onScoreBreakdownTap,
    this.onFullProfileTap,
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
  final bool interestedInYou;
  final VoidCallback? onScoreBreakdownTap;
  final VoidCallback? onFullProfileTap;

  @override
  Widget build(BuildContext context) {
    final ageLabel = age != null ? ', $age' : '';
    final card = _Daily5ProfileCardBody(
      ageLabel: ageLabel,
      name: name,
      subtitle: subtitle,
      prompts: prompts,
      tags: tags,
      compatibilityScore: compatibilityScore,
      matchReasonLabel: matchReasonLabel,
      matchReasonField: matchReasonField,
      trustTier: trustTier,
      imageUrl: imageUrl,
      onScoreBreakdownTap: onScoreBreakdownTap,
      onFullProfileTap: onFullProfileTap,
    );

    if (!interestedInYou) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.r20,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: ClipRRect(borderRadius: AppRadius.r20, child: card),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.r20,
              border: Border.all(color: AppColors.mint, width: 1.5),
            ),
            child: ClipRRect(borderRadius: AppRadius.r20, child: card),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: _GooeyInterestTab()),
        ),
      ],
    );
  }
}

class _GooeyInterestTab extends StatelessWidget {
  const _GooeyInterestTab();

  static const _ink = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.mint, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PhosphorIconsFill.heart,
                  size: 12,
                  color: _ink,
                ),
                const SizedBox(width: 6),
                Text(
                  "They're interested in you",
                  style: AppTypography.chip(color: _ink).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Daily5ProfileCardBody extends StatelessWidget {
  const _Daily5ProfileCardBody({
    required this.ageLabel,
    required this.name,
    required this.subtitle,
    required this.prompts,
    required this.tags,
    required this.compatibilityScore,
    required this.matchReasonLabel,
    required this.matchReasonField,
    required this.trustTier,
    required this.imageUrl,
    required this.onScoreBreakdownTap,
    required this.onFullProfileTap,
  });

  final String ageLabel;
  final String name;
  final String subtitle;
  final List<({String question, String answer})> prompts;
  final List<String> tags;
  final int compatibilityScore;
  final String? matchReasonLabel;
  final String? matchReasonField;
  final String trustTier;
  final String? imageUrl;
  final VoidCallback? onScoreBreakdownTap;
  final VoidCallback? onFullProfileTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.s2,
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
              const Positioned.fill(child: _PhotoGradientOverlay()),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: VcTrustBadge.trustTier(trustTier),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
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
                    onDarkBackground: true,
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
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (tags.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final tag in tags)
                        VcChip(label: tag, variant: VcChipVariant.muted),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Daily5CompactActionButton(
                        icon: PhosphorIconsRegular.chartBar,
                        label: 'Score breakdown',
                        onTap: onScoreBreakdownTap,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Daily5CompactActionButton(
                        icon: PhosphorIconsRegular.userRectangle,
                        label: 'Full profile',
                        onTap: onFullProfileTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGradientOverlay extends StatelessWidget {
  const _PhotoGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.28, 0.62, 1.0],
          colors: [
            AppColors.bg.withValues(alpha: 0.55),
            Colors.transparent,
            AppColors.bg.withValues(alpha: 0.35),
            AppColors.bg.withValues(alpha: 0.92),
          ],
        ),
      ),
    );
  }
}
