import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';

/// Phone OTP via Firebase Auth.
class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String formatPhone(String digits) => '+91$digits';

  Future<void> sendOtp(String phoneDigits) {
    final completer = Completer<void>();

    _auth.verifyPhoneNumber(
      phoneNumber: formatPhone(phoneDigits),
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (_) {
        // Android auto-retrieval — ignore; user still enters code on iOS.
      },
      verificationFailed: (e) {
        if (kDebugMode) {
          debugPrint(
            'Firebase phone auth failed: code=${e.code} message=${e.message}',
          );
        }
        if (!completer.isCompleted) {
          completer.completeError(
            FirebaseAuthException(code: e.code, message: e.message),
          );
        }
      },
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        _resendToken = forceResendingToken;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );

    return completer.future;
  }

  Future<UserCredential> verifyOtp({required String token}) {
    final verificationId = _verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'Request a new code and try again.',
      );
    }

    if (kDebugMode) {
      debugPrint('Firebase verifyOtp: verificationId=$verificationId');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: token,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Signs out of Firebase and clears local registration state for this user.
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    resetVerification();
    await _auth.signOut();
    if (uid != null) {
      RegistrationService.instance.clear(uid);
      await LocalCache.clearUser(uid);
    }
  }

  void resetVerification() {
    _verificationId = null;
    _resendToken = null;
  }
}
