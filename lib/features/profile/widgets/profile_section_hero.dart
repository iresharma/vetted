import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/molecules/vc_soft_card.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_visuals.dart';

/// Decorative hero strip for a profile section — gradient blob + floating icons.
class ProfileSectionHero extends StatelessWidget {
  const ProfileSectionHero({
    super.key,
    required this.sectionId,
  });

  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);
    final icons = ProfileFieldVisuals.sectionHeroIcons(sectionId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: VcSoftCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -20,
                top: -16,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.main.withValues(alpha: 0.35),
                        accent.main.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -12,
                bottom: -8,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.dim,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    for (var i = 0; i < icons.length; i++)
                      Padding(
                        padding: EdgeInsets.only(right: i < icons.length - 1 ? 10 : 0),
                        child: _HeroIconBubble(
                          icon: icons[i],
                          accent: accent,
                          size: i == 0 ? 44 : 36,
                          offset: i == 1 ? 4 : 0,
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: accent.main.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroIconBubble extends StatelessWidget {
  const _HeroIconBubble({
    required this.icon,
    required this.accent,
    required this.size,
    this.offset = 0,
  });

  final IconData icon;
  final AccentColor accent;
  final double size;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.s3,
          borderRadius: BorderRadius.circular(size / 2.8),
          border: Border.all(color: accent.main.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: accent.main.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.48,
          color: accent.main,
        ),
      ),
    );
  }
}

/// Label row with tinted icon for form fields.
class ProfileFieldLabel extends StatelessWidget {
  const ProfileFieldLabel({
    super.key,
    required this.fieldId,
    required this.label,
    this.accent = AccentColor.violet,
  });

  final String fieldId;
  final String label;
  final AccentColor accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accent.dim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ProfileFieldVisuals.fieldIcon(fieldId),
            size: 15,
            color: accent.main,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: AppTypography.eyebrow()),
        ),
      ],
    );
  }
}
