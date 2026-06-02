import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

/// Shown after verification — explains the four profile steps before biodata.
class ProfileIntroScreen extends StatelessWidget {
  const ProfileIntroScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      ctaLabel: 'Start building →',
      onCta: onContinue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '4-step profile',
            style: AppTypography.eyebrow(color: AppColors.violet),
          ),
          const SizedBox(height: 8),
          Text(
            'Build your\nbiodata.',
            style: AppTypography.display().copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Four quick sections to show who you are. No long forms — just the '
            'essentials that help us match you well.',
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),
          const VcSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                VcFlowStepRow(
                  stepNumber: 1,
                  title: 'You & photos',
                  detail: 'Basics, prompts, and your best shots',
                  icon: Icons.person_outline_rounded,
                  accent: AppColors.violet,
                ),
                Divider(height: 0.5, color: AppColors.border),
                VcFlowStepRow(
                  stepNumber: 2,
                  title: 'Interests',
                  detail: 'Hobbies, passions, what you\'re into',
                  icon: Icons.interests_outlined,
                  accent: AppColors.mint,
                ),
                Divider(height: 0.5, color: AppColors.border),
                VcFlowStepRow(
                  stepNumber: 3,
                  title: 'Career',
                  detail: 'Work, education, and ambition',
                  icon: Icons.work_outline_rounded,
                  accent: AppColors.amber,
                ),
                Divider(height: 0.5, color: AppColors.border),
                VcFlowStepRow(
                  stepNumber: 4,
                  title: 'Cultural',
                  detail: 'Faith, family, lifestyle, and values',
                  icon: Icons.public_outlined,
                  accent: AppColors.coral,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'About five minutes total. Your Daily 5 unlocks once you\'re done.',
            textAlign: TextAlign.center,
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
