import 'package:cloud_functions/cloud_functions.dart';
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

  static String get _emulatorHost =>
      dotenv.env['FUNCTIONS_EMULATOR_HOST']?.trim().isNotEmpty == true
          ? dotenv.env['FUNCTIONS_EMULATOR_HOST']!.trim()
          : 'localhost';

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
    }
    _configured = true;
  }

  Future<Map<String, dynamic>> call(
    String name, {
    Map<String, dynamic>? data,
  }) async {
    final callable = _functions.httpsCallable(
      name,
      options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
    );
    final response = await callable.call<Map<String, dynamic>>(data ?? {});
    return response.data;
  }
}
