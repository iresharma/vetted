import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/home/home_screen.dart';
import 'package:vetted_club_mobile/features/onboarding/onboarding_screen.dart';
import 'package:vetted_club_mobile/features/registration/registration_flow_screen.dart';

/// Routes between authenticated and unauthenticated flows based on Firebase
/// session state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const _AuthLoading();
        }

        final user = snapshot.data;
        if (user != null) {
          if (!RegistrationService.instance.isComplete(user.uid)) {
            return RegistrationFlowScreen(user: user);
          }
          return HomeScreen(user: user);
        }

        // Isolated stack so auth transitions dispose phone/OTP routes cleanly.
        return Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) {
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
}
