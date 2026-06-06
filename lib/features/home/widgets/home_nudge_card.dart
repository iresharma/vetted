import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/home/widgets/home_action_card.dart';

enum HomeNudgeKind { verifyIdentity, completeProfile }

class HomeNudgeCard extends StatelessWidget {
  const HomeNudgeCard({
    super.key,
    required this.kind,
    required this.onTap,
  });

  final HomeNudgeKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, body, icon) = switch (kind) {
      HomeNudgeKind.verifyIdentity => (
          'Verify your identity',
          'Complete DigiLocker verification to unlock matching.',
          PhosphorIconsRegular.shieldWarning,
        ),
      HomeNudgeKind.completeProfile => (
          'Finish your profile',
          'Add the remaining details so you can go live on Daily 5.',
          PhosphorIconsRegular.userCircle,
        ),
    };

    return HomeActionCard(
      icon: icon,
      iconColor: AppColors.amber,
      iconBackground: AppColors.amberDim,
      title: title,
      subtitle: body,
      onTap: onTap,
    );
  }
}
