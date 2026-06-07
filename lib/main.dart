import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/app.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/config/app_check_bootstrap.dart';
import 'package:vetted_club_mobile/core/config/app_check_debug.dart';
import 'package:vetted_club_mobile/core/config/app_env.dart';
import 'package:vetted_club_mobile/core/config/giphy_bootstrap.dart';
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

  GiphyBootstrap.configure();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await activateAppCheck();

  await LocalCache.init();

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

  runApp(
    const ProviderScope(
      child: VettedClubApp(),
    ),
  );
}
