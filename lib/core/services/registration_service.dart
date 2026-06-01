import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetted_club_mobile/core/services/functions_service.dart';

class RegistrationStatus {
  const RegistrationStatus({
    required this.exists,
    required this.hasPaidEntryPass,
    required this.isIdentityVerified,
    required this.isRegistrationComplete,
  });

  final bool exists;
  final bool hasPaidEntryPass;
  final bool isIdentityVerified;
  final bool isRegistrationComplete;

  factory RegistrationStatus.fromMap(Map<String, dynamic> map) {
    bool asBool(String key) => map[key] == true;
    return RegistrationStatus(
      exists: asBool('exists'),
      hasPaidEntryPass: asBool('hasPaidEntryPass'),
      isIdentityVerified: asBool('isIdentityVerified'),
      isRegistrationComplete: asBool('isRegistrationComplete'),
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
