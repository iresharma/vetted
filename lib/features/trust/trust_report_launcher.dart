import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/features/trust/screens/trust_report_screen.dart';

abstract final class TrustReportLauncher {
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TrustReportScreen(
          showBackButton: true,
          user: AuthService.instance.currentUser,
        ),
      ),
    );
  }
}
