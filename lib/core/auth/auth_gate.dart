import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/home/home_screen.dart';
import 'package:vetted_club_mobile/features/onboarding/onboarding_screen.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_screen.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
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
          return _SignedInGate(key: ValueKey(user.uid), user: user);
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

/// Loads registration status once per sign-in (avoids duplicate calls on rebuild).
class _SignedInGate extends ConsumerStatefulWidget {
  const _SignedInGate({super.key, required this.user});

  final User user;

  @override
  ConsumerState<_SignedInGate> createState() => _SignedInGateState();
}

class _SignedInGateState extends ConsumerState<_SignedInGate> {
  RegistrationStatus? _status;
  bool _loading = true;
  bool _loadError = false;
  bool _profileEnteredClub = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cached = LocalCache.readRegistrationStatus(widget.user.uid);
    if (cached != null) {
      setState(() {
        _status = cached;
        _loading = false;
      });
      Future.microtask(() {
        if (mounted) {
          ref.read(registrationStatusProvider.notifier).cache(cached);
        }
      });
    }

    try {
      final status =
          await RegistrationService.instance.refreshStatus(widget.user.uid);
      await LocalCache.writeRegistrationStatus(widget.user.uid, status);
      RegistrationService.instance.cacheStatus(widget.user.uid, status);
      if (mounted) {
        ref.read(registrationStatusProvider.notifier).cache(status);
        setState(() {
          _status = status;
          _loading = false;
          _loadError = false;
        });
      }
    } catch (_) {
      if (mounted && _status == null) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  void _onProfileComplete() {
    setState(() => _profileEnteredClub = true);
    _bootstrap();
  }

  void _retryStatus() {
    setState(() {
      _loading = _status == null;
      _loadError = false;
    });
    _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _status == null) {
      return const _AuthLoading();
    }

    if (_loadError && _status == null) {
      return _BackendError(
        message: 'Could not reach the server. Check your connection and retry.',
        onRetry: _retryStatus,
      );
    }

    final status = _status!;

    if (!status.isRegistrationComplete) {
      return RegistrationFlowScreen(
        user: widget.user,
        initialStatus: status,
      );
    }
    if (!status.isProfileComplete && !_profileEnteredClub) {
      return ProfileFlowScreen(
        user: widget.user,
        onProfileComplete: _onProfileComplete,
      );
    }
    return HomeScreen(user: widget.user);
  }
}

class _AuthLoading extends StatelessWidget {
  const _AuthLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: VcLoadingIndicator(logoSize: 72),
      ),
    );
  }
}

class _BackendError extends StatelessWidget {
  const _BackendError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
