import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Signs the user out and shows an error snackbar on failure.
///
/// Returns `true` when sign-out succeeded. [AuthGate] handles navigation after
/// Firebase emits a null user.
Future<bool> signOutUser(BuildContext context) async {
  try {
    await AuthService.instance.signOut();
    return true;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not sign out. Please try again.',
            style: AppTypography.supporting(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.s3,
        ),
      );
    }
    return false;
  }
}
