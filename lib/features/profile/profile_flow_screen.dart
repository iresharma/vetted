import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/auth/sign_out.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_intro_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_you_and_photos_screen.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

enum _ProfileStep { intro, userData, interests }

/// Post-verification profile creation: intro → four biodata steps.
class ProfileFlowScreen extends StatefulWidget {
  const ProfileFlowScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileFlowScreen> createState() => _ProfileFlowScreenState();
}

class _ProfileFlowScreenState extends State<ProfileFlowScreen> {
  _ProfileStep _step = _ProfileStep.intro;
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);

    final ok = await signOutUser(context);
    if (!ok && mounted) setState(() => _signingOut = false);
  }

  void _goTo(_ProfileStep step) {
    if (_step == step) return;
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: AppMotion.slideDuration,
          switchInCurve: AppMotion.standardCurve,
          switchOutCurve: AppMotion.standardCurve,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: switch (_step) {
            _ProfileStep.intro => ProfileIntroScreen(
                key: const ValueKey('profile_intro'),
                onContinue: () => _goTo(_ProfileStep.userData),
              ),
            _ProfileStep.userData => ProfileYouAndPhotosScreen(
                key: const ValueKey('profile_user_data'),
                onContinue: () => _goTo(_ProfileStep.interests),
              ),
            _ProfileStep.interests => _ProfileStepPlaceholder(
                key: const ValueKey('profile_interests'),
                stepIndex: 1,
                title: 'Interests',
                detail: 'Hobbies, passions, what you\'re into',
              ),
          },
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _signingOut ? null : _signOut,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                _signingOut ? 'Signing out…' : 'Sign out',
                style: AppTypography.supporting(color: AppColors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Temporary shell until the next profile step is built.
class _ProfileStepPlaceholder extends StatelessWidget {
  const _ProfileStepPlaceholder({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.detail,
  });

  final int stepIndex;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      header: ProfileStepHeader(stepIndex: stepIndex),
      ctaLabel: 'Continue →',
      ctaEnabled: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.display().copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail,
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'This step is next up — we\'ll wire the form here.',
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
