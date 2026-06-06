import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Whether to use App Check debug providers (simulator / local dev).
bool get useAppCheckDebugProviders {
  if (kDebugMode) return true;
  final raw = dotenv.env['APP_CHECK_DEBUG']?.trim().toLowerCase();
  return raw == 'true' || raw == '1' || raw == 'yes';
}

/// Activate App Check immediately after [Firebase.initializeApp].
///
/// On iOS Simulator, DeviceCheck is unavailable — debug provider must be
/// active before any Firebase SDK call (see AppDelegate debug factory too).
Future<void> activateAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    providerAndroid: useAppCheckDebugProviders
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: useAppCheckDebugProviders
        ? const AppleDebugProvider()
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );

  if (useAppCheckDebugProviders) {
    await primeAppCheckToken();
  }
}

/// Fetches a debug/production App Check token with short retries.
Future<void> primeAppCheckToken({bool forceRefresh = false}) async {
  for (var attempt = 0; attempt < 4; attempt++) {
    try {
      await FirebaseAppCheck.instance.getToken(
        forceRefresh || attempt > 0,
      );
      return;
    } catch (e) {
      if (attempt == 3) {
        debugPrint('App Check: token not ready ($e)');
        return;
      }
      await Future<void>.delayed(
        Duration(milliseconds: 250 * (attempt + 1)),
      );
    }
  }
}
