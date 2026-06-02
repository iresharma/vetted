import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/app.dart';
import 'package:vetted_club_mobile/core/config/app_check_debug.dart';
import 'package:vetted_club_mobile/core/config/app_env.dart';
import 'package:vetted_club_mobile/core/services/functions_service.dart';
import 'package:vetted_club_mobile/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppEnv.load();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('AppEnv: .env not loaded ($e). Copy .env.example → .env');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerAndroid:
        kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
    providerApple:
        kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );

  FunctionsService.instance.configure();

  if (kDebugMode) {
    // Log after first frame so it does not race with App Check / Auth on hot restart.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logAppCheckDebugToken();
    });
  }

  // Simulator/dev: skip real reCAPTCHA. Add the number in Firebase Console →
  // Authentication → Sign-in method → Phone → Phone numbers for testing.
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  runApp(const VettedClubApp());
}
