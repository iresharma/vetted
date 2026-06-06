import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_action_card.dart';

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

    return HomeActionCard(
      icon: PhosphorIconsRegular.calendarStar,
      iconColor: AppColors.coral,
      iconBackground: AppColors.coralDim,
      label: 'IRL events',
      labelColor: AppColors.coral,
      title: 'Meet members offline',
      subtitle: locationLine,
      showChevron: false,
      trailing: const VcTrustBadge(
        label: 'Coming soon',
        variant: VcTrustBadgeVariant.amber,
      ),
    );
  }
}
