import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// User-facing auth errors + setup hints.
abstract final class AuthErrors {
  static const unsupportedRegion =
      "We don't serve your country yet. Vetted Club is available in select regions only.";

  static const verificationFailed =
      "We couldn't send a verification code. Please try again in a moment.";

  static const appCheckDebugHint =
      'Simulator/dev: register the App Check debug token printed at app '
      'startup in Firebase Console → App Check → your iOS app → '
      'Manage debug tokens, then fully restart the app (not hot restart).';

  static const devPhoneHint =
      'Simulator/dev: add +91XXXXXXXXXX and a test code (e.g. 123456) in '
      'Firebase Console → Authentication → Sign-in method → Phone → '
      'Phone numbers for testing.';

  static const phoneSetupHint =
      'Enable Phone sign-in in Firebase Console → Authentication → Sign-in method. '
      'On iOS, complete the reCAPTCHA check when prompted.';

  static const networkError =
      "Couldn't reach Firebase — request timed out. "
      'Check Wi‑Fi, disable VPN, then fully restart the app.';

  static String fromException(Object e) {
    final text = e.toString().toLowerCase();
    if (text.contains('socketexception') ||
        text.contains('timed out') ||
        text.contains('timeout') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('clientexception')) {
      return networkError;
    }
    if (kDebugMode) return e.toString();
    return 'Something went wrong. Please try again.';
  }

  static String sendOtp(FirebaseAuthException e) {
    final msg = (e.message ?? e.code).toLowerCase();
    if (msg.contains('region enabled') ||
        msg.contains('unsupported-region') ||
        msg.contains('sms unable to be sent')) {
      return unsupportedRegion;
    }
    if (e.code == 'missing-client-identifier' ||
        msg.contains('missing-client-identifier') ||
        msg.contains('client identifier')) {
      return kDebugMode
          ? 'Phone verification needs a registered App Check debug token on '
              'this simulator.\n$appCheckDebugHint\n$devPhoneHint'
          : verificationFailed;
    }
    if (e.code == 'internal-error' || msg.contains('internal error')) {
      return kDebugMode ? '$verificationFailed\n$devPhoneHint' : verificationFailed;
    }
    if (msg.contains('web-internal-error') ||
        msg.contains('recaptcha') ||
        msg.contains('captcha-check-failed')) {
      return 'Verification check failed. Please try again.';
    }
    if (msg.contains('invalid-phone-number')) {
      return 'Invalid phone number. Use 10 digits without country code.';
    }
    if (msg.contains('quota') || msg.contains('too-many-requests')) {
      return 'Too many attempts. Wait a minute and try again.';
    }
    if (msg.contains('captcha') || msg.contains('app-not-authorized')) {
      return 'Firebase blocked this device. $phoneSetupHint';
    }
    if (msg.contains('billing') || msg.contains('operation-not-allowed')) {
      return 'Phone sign-in is not enabled. $phoneSetupHint';
    }
    return e.message ?? e.code;
  }

  static String verifyOtp(FirebaseAuthException e) {
    final msg = (e.message ?? e.code).toLowerCase();
    if (e.code == 'missing-verification-id') {
      return 'Session expired. Go back and request a new code.';
    }
    if (msg.contains('invalid') ||
        msg.contains('expired') ||
        msg.contains('session-expired')) {
      return 'That code is wrong or expired. Tap Resend code and try again.';
    }
    return e.message ?? e.code;
  }
}
