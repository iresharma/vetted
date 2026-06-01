import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('com.vettedclub/app_check_debug');

/// Logs the App Check debug token to the Flutter console (debug builds only).
///
/// Register the printed UUID in Firebase Console → App Check → your app →
/// Manage debug tokens.
Future<void> logAppCheckDebugToken() async {
  if (!kDebugMode) return;

  String? debugToken;
  try {
    debugToken = await _channel.invokeMethod<String>('getDebugToken');
  } on PlatformException catch (e) {
    debugPrint('App Check: could not read debug token natively (${e.code})');
  }

  // Triggers token generation; on Android the native side may resolve the secret
  // from storage after this call.
  if (debugToken == null || debugToken.isEmpty) {
    try {
      await FirebaseAppCheck.instance.getToken(true);
      debugToken = await _channel.invokeMethod<String>('getDebugToken');
    } catch (e) {
      debugPrint('App Check: getToken failed ($e)');
    }
  }

  if (debugToken != null && debugToken.isNotEmpty) {
    debugPrint(_banner(debugToken));
    return;
  }

  debugPrint(
    'App Check: debug token not available yet. '
    'Search device logs for "Firebase App Check Debug Token" (iOS) or '
    '"DebugAppCheckProvider" (Android), then register it in Firebase Console → '
    'App Check → Manage debug tokens.',
  );
}

String _banner(String token) => '''

══════════════════════════════════════════════════════════════
Firebase App Check DEBUG TOKEN — add in Firebase Console:
  App Check → Apps → (your app) → Manage debug tokens

$token
══════════════════════════════════════════════════════════════
''';
