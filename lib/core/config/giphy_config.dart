import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class GiphyConfig {
  static String? get apiKey {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return _readKey('GIPHY_ANDROID_API_KEY');
    }
    if (Platform.isIOS) {
      return _readKey('GIPHY_IOS_API_KEY');
    }
    return null;
  }

  static bool get isAvailable {
    final key = apiKey;
    return key != null && key.isNotEmpty;
  }

  static String? _readKey(String name) {
    final value = dotenv.env[name]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
