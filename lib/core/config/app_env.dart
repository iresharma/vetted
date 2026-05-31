import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads secrets and environment-specific config from `.env`.
abstract final class AppEnv {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
