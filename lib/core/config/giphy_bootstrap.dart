import 'package:flutter/foundation.dart';
import 'package:giphy_flutter_sdk/giphy_flutter_sdk.dart';
import 'package:vetted_club_mobile/core/config/giphy_config.dart';

abstract final class GiphyBootstrap {
  static bool _configured = false;

  static bool get isConfigured => _configured;

  static void configure() {
    if (_configured) return;

    final apiKey = GiphyConfig.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'GiphyBootstrap: missing platform API key. '
          'Set GIPHY_ANDROID_API_KEY / GIPHY_IOS_API_KEY in .env',
        );
      }
      return;
    }

    GiphyFlutterSDK.configure(apiKey: apiKey);
    _configured = true;
  }
}
