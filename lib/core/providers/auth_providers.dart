import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges;
});

final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authUserProvider).value?.uid;
});
