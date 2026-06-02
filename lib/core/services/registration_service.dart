import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetted_club_mobile/core/services/functions_service.dart';

/// Gate progress for the post-auth registration flow.
enum RegistrationGate {
  /// Verification intro (first-time only).
  intro,

  /// Membership / entry pass payment.
  entryPass,

  /// DigiLocker identity step.
  digilocker,

  /// Welcome / you're in.
  welcome,
}

class RegistrationStatus {
  const RegistrationStatus({
    required this.exists,
    required this.hasPaidEntryPass,
    required this.hasActiveSubscription,
    required this.isIdentityVerified,
    required this.isRegistrationComplete,
    required this.isProfileComplete,
    this.completenessPct = 0,
  });

  final bool exists;
  final bool hasPaidEntryPass;
  final bool hasActiveSubscription;
  final bool isIdentityVerified;
  final bool isRegistrationComplete;
  final bool isProfileComplete;
  final int completenessPct;

  /// Paid entry pass and/or an active Razorpay subscription row.
  bool get hasMembership => hasPaidEntryPass || hasActiveSubscription;

  /// Which registration screen to show when resuming after app restart.
  RegistrationGate get resumeGate {
    if (isRegistrationComplete) return RegistrationGate.welcome;
    if (!hasMembership) {
      return exists ? RegistrationGate.entryPass : RegistrationGate.intro;
    }
    if (!isIdentityVerified) return RegistrationGate.digilocker;
    return RegistrationGate.welcome;
  }

  factory RegistrationStatus.fromMap(Map<String, dynamic> map) {
    bool asBool(String key) => map[key] == true;
    return RegistrationStatus(
      exists: asBool('exists'),
      hasPaidEntryPass: asBool('hasPaidEntryPass'),
      hasActiveSubscription: asBool('hasActiveSubscription'),
      isIdentityVerified: asBool('isIdentityVerified'),
      isRegistrationComplete: asBool('isRegistrationComplete'),
      isProfileComplete: asBool('isProfileComplete'),
      completenessPct: (map['completenessPct'] as num?)?.toInt() ?? 0,
    );
  }
}

class RegistrationService {
  RegistrationService._();

  static final RegistrationService instance = RegistrationService._();

  final Map<String, RegistrationStatus> _statusByUserId = {};

  bool isComplete(String uid) =>
      _statusByUserId[uid]?.isRegistrationComplete ?? false;

  RegistrationStatus? statusFor(String uid) => _statusByUserId[uid];

  void cacheStatus(String uid, RegistrationStatus status) {
    _statusByUserId[uid] = status;
  }

  Future<void> bootstrap(User user) async {
    await FunctionsService.instance.call(
      'upsertUserFromAuth',
      data: const {},
    );
    await refreshStatus(user.uid);
  }

  Future<RegistrationStatus> refreshStatus(String uid) async {
    final response = await FunctionsService.instance.call(
      'getRegistrationStatus',
      data: const {},
    );
    final status = RegistrationStatus.fromMap(response);
    _statusByUserId[uid] = status;
    return status;
  }

  Future<void> markIdentityVerified({
    required String verifiedName,
    required String verifiedDob,
    required int verifiedAge,
  }) async {
    await FunctionsService.instance.call(
      'markIdentityVerified',
      data: {
        'verified_name': verifiedName,
        'verified_dob': verifiedDob,
        'verified_age': verifiedAge,
      },
    );
  }

  Future<void> saveProfileStep(Map<String, dynamic> payload) async {
    await FunctionsService.instance.call('saveProfileStep', data: payload);
  }

  Future<void> savePreferencesStep(Map<String, dynamic> payload) async {
    await FunctionsService.instance.call('savePreferencesStep', data: payload);
  }

  void clear(String uid) {
    _statusByUserId.remove(uid);
  }
}
