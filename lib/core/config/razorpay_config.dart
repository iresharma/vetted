import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Razorpay credentials from `.env`. Never commit real secrets.
abstract final class RazorpayConfig {
  static const membershipAmountInr = '199.00';
  static const membershipAmountPaise = 19900;
  static const appName = 'Vetted Club';
  static const membershipPlanName = 'Vetted Club Membership';

  /// Billing cycles for the subscription (120 ≈ 10 years monthly).
  static const subscriptionTotalCount = 120;

  static String get keyId => dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? '';

  static bool get isTestMode => keyId.startsWith('rzp_test_');

  static bool get isConfigured => keyId.isNotEmpty;

  /// Skip checkout while developing. Set `PAYMENT_BYPASS=true` in `.env`.
  static bool get bypassPayment {
    final raw = dotenv.env['PAYMENT_BYPASS']?.trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
