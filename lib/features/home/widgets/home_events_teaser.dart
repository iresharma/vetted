import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Placeholder until IRL events ship — keeps Home layout ready for the real hero.
class HomeEventsTeaser extends StatelessWidget {
  const HomeEventsTeaser({super.key, this.city});

  final String? city;

  @override
  Widget build(BuildContext context) {
    final cityLabel = city?.trim();
    final locationLine = cityLabel != null && cityLabel.isNotEmpty
        ? 'Curated meetups in $cityLabel are on the way.'
        : 'Curated in-person meetups are on the way.';

    return ClipRRect(
      borderRadius: AppRadius.r16,
      child: Material(
        color: AccentColor.coral.dim,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.calendarStar,
                    size: 18,
                    color: AccentColor.coral.main,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'IRL events',
                    style: AppTypography.labelCaps(color: AccentColor.coral.main),
                  ),
                  const Spacer(),
                  Text(
                    'Coming soon',
                    style: AppTypography.chip(color: AppColors.amber),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Meet members offline',
                style: AppTypography.title().copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(locationLine, style: AppTypography.supporting()),
            ],
          ),
        ),
      ),
    );
  }
}
