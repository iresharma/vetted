import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FunctionsService {
  FunctionsService._();

  static final FunctionsService instance = FunctionsService._();

  late final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: _region,
  );

  static String get _region =>
      dotenv.env['FUNCTIONS_REGION']?.trim().isNotEmpty == true
          ? dotenv.env['FUNCTIONS_REGION']!.trim()
          : 'asia-south1';

  static bool get _useEmulator {
    final raw = dotenv.env['FUNCTIONS_USE_EMULATOR']?.trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static String get _emulatorHost {
    final raw = dotenv.env['FUNCTIONS_EMULATOR_HOST']?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    // iOS simulator cannot reach host "localhost" on the Mac — use loopback IP.
    return defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1';
  }

  static int get _emulatorPort {
    final raw = dotenv.env['FUNCTIONS_EMULATOR_PORT']?.trim();
    return int.tryParse(raw ?? '') ?? 5001;
  }

  bool _configured = false;

  void configure() {
    if (_configured) return;
    if (_useEmulator) {
      _functions.useFunctionsEmulator(_emulatorHost, _emulatorPort);
      if (kDebugMode) {
        debugPrint('Functions emulator: $_emulatorHost:$_emulatorPort');
      }
    } else if (kDebugMode) {
      debugPrint('Cloud Functions region: $_region');
    }
    _configured = true;
  }

  /// Ensures Auth + App Check tokens exist before the first callable (helps after hot restart).
  Future<void> _warmUp() async {
    try {
      await FirebaseAppCheck.instance.getToken(false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Functions warm-up: App Check token not ready ($e)');
      }
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.getIdToken(false);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Functions warm-up: Auth token not ready ($e)');
        }
      }
    }
  }

  static bool _isRetryable(FirebaseFunctionsException e) {
    if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
      return true;
    }
    if (e.code != 'unknown') return false;
    final msg = (e.message ?? '').toLowerCase();
    return msg.contains('network') ||
        msg.contains('timeout') ||
        msg.contains('unreachable') ||
        msg.contains('connection');
  }

  Future<Map<String, dynamic>> call(
    String name, {
    Map<String, dynamic>? data,
  }) async {
    await _warmUp();

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        final delayMs = 400 * attempt;
        if (kDebugMode) {
          debugPrint('Functions retry $attempt for $name in ${delayMs}ms');
        }
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        await _warmUp();
      }

      try {
        final callable = _functions.httpsCallable(
          name,
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 60),
          ),
        );
        final response = await callable.call<Map<String, dynamic>>(data ?? {});
        return response.data;
      } on FirebaseFunctionsException catch (e, st) {
        lastError = e;
        if (!_isRetryable(e) || attempt == 2) {
          if (kDebugMode) {
            debugPrint('Functions $name failed: ${e.code} ${e.message}');
            debugPrint('$st');
          }
          rethrow;
        }
      }
    }

    throw lastError ?? Exception('Functions call failed: $name');
  }
}
