import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

/// Shown right after OTP — explains the two-step verification before payment.
class VerificationIntroScreen extends StatelessWidget {
  const VerificationIntroScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      ctaLabel: 'Continue →',
      onCta: onContinue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '2-step verification',
            style: AppTypography.eyebrow(color: AppColors.violet),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s make sure\nyou\'re all in.',
            style: AppTypography.display().copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Two quick steps to join Vetted Club. Everyone on the app goes through the same checks — no shortcuts.',
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
                _VerificationStepRow(
                  stepNumber: 1,
                  title: 'Membership',
                  detail: '₹199/month · Secured by Razorpay',
                  icon: Icons.credit_card_rounded,
                  accent: AppColors.violet,
                ),
                Divider(height: 0.5, color: AppColors.border),
                _VerificationStepRow(
                  stepNumber: 2,
                  title: 'DigiLocker',
                  detail: 'Government ID · Real name & age',
                  icon: Icons.verified_user_outlined,
                  accent: AppColors.mint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Takes about two minutes. You can sign out anytime from the top right.',
            textAlign: TextAlign.center,
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _VerificationStepRow extends StatelessWidget {
  const _VerificationStepRow({
    required this.stepNumber,
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final int stepNumber;
  final String title;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $stepNumber · $title',
                  style: AppTypography.body().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTypography.supporting(color: AppColors.textSecondary)
                      .copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
