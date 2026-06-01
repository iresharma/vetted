import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/auth/sign_out.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/registration/screens/digilocker_screen.dart';
import 'package:vetted_club_mobile/features/registration/screens/entry_pass_screen.dart';
import 'package:vetted_club_mobile/features/registration/screens/verification_intro_screen.dart';
import 'package:vetted_club_mobile/features/registration/screens/youre_in_screen.dart';

enum _RegistrationStep { intro, entryPass, digilocker, youreIn }

/// Post-auth registration: intro → membership → DigiLocker → welcome.
class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key, required this.user});

  final User user;

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  _RegistrationStep _step = _RegistrationStep.intro;
  bool _signingOut = false;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await RegistrationService.instance.bootstrap(widget.user);
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);

    final ok = await signOutUser(context);
    if (!ok && mounted) setState(() => _signingOut = false);
  }

  void _goTo(_RegistrationStep step) {
    if (_step == step) return;
    setState(() => _step = step);
  }

  Future<void> _completeRegistration() async {
    await RegistrationService.instance.refreshStatus(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.violet,
            strokeWidth: 2,
          ),
        ),
      );
    }

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
            _RegistrationStep.intro => VerificationIntroScreen(
                key: const ValueKey('verification_intro'),
                onContinue: () => _goTo(_RegistrationStep.entryPass),
              ),
            _RegistrationStep.entryPass => EntryPassScreen(
                key: const ValueKey('entry_pass'),
                customerId: widget.user.uid,
                onContinue: () => _goTo(_RegistrationStep.digilocker),
              ),
            _RegistrationStep.digilocker => DigilockerScreen(
                key: const ValueKey('digilocker'),
                customerId: widget.user.uid,
                onVerified: () => _goTo(_RegistrationStep.youreIn),
              ),
            _RegistrationStep.youreIn => YoureInScreen(
                key: const ValueKey('youre_in'),
                onBuildBiodata: () {
                  _completeRegistration();
                },
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
