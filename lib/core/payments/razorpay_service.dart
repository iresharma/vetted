import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vetted_club_mobile/core/config/razorpay_config.dart';
import 'package:vetted_club_mobile/core/services/functions_service.dart';

enum RazorpayPaymentStatus { success, cancelled, failed }

class RazorpayPaymentResult {
  const RazorpayPaymentResult({
    required this.status,
    this.message,
    this.orderId,
    this.paymentId,
    this.subscriptionId,
    this.raw,
    this.signature,
  });

  final RazorpayPaymentStatus status;
  final String? message;
  final String? orderId;
  final String? paymentId;
  final String? subscriptionId;
  final Map<String, String>? raw;
  final String? signature;
}

class RazorpayNotConfiguredException implements Exception {
  @override
  String toString() =>
      'Razorpay is not configured. Add RAZORPAY_KEY_ID to .env';
}

/// Razorpay Subscriptions — ₹199/month via Checkout (`subscription_id`).
/// Sensitive API interactions run in Firebase Functions.
class RazorpayService {
  RazorpayService._();

  static final RazorpayService instance = RazorpayService._();

  Razorpay? _razorpay;
  Completer<RazorpayPaymentResult>? _pending;
  String? _activeSubscriptionId;

  void _ensureInitialized() {
    _razorpay ??= Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    final completer = _pending;
    if (completer == null || completer.isCompleted) return;

    completer.complete(
      RazorpayPaymentResult(
        status: RazorpayPaymentStatus.success,
        orderId: response.orderId,
        paymentId: response.paymentId,
        subscriptionId: _activeSubscriptionId,
        message: 'Subscription activated',
        raw: {
          'paymentId': response.paymentId ?? '',
          'orderId': response.orderId ?? '',
          'subscriptionId': _activeSubscriptionId ?? '',
          'signature': response.signature ?? '',
        },
        signature: response.signature,
      ),
    );
    _pending = null;
    _activeSubscriptionId = null;
  }

  void _onError(PaymentFailureResponse response) {
    final completer = _pending;
    if (completer == null || completer.isCompleted) return;

    final code = response.code;
    final message = response.message ?? 'Payment failed';
    final isCancel = code == Razorpay.PAYMENT_CANCELLED;

    completer.complete(
      RazorpayPaymentResult(
        status: isCancel
            ? RazorpayPaymentStatus.cancelled
            : RazorpayPaymentStatus.failed,
        message: message,
        subscriptionId: _activeSubscriptionId,
        raw: {
          'code': '$code',
          'message': message,
        },
      ),
    );
    _pending = null;
    _activeSubscriptionId = null;
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      debugPrint('Razorpay external wallet: ${response.walletName}');
    }
  }

  /// Starts a ₹199/month Razorpay subscription and opens Checkout for mandate + first charge.
  Future<RazorpayPaymentResult> payMembership({
    required String customerId,
  }) async {
    if (RazorpayConfig.bypassPayment) {
      if (kDebugMode) {
        debugPrint('Razorpay bypass: skipping subscription checkout');
      }
      return RazorpayPaymentResult(
        status: RazorpayPaymentStatus.success,
        subscriptionId: 'bypass_sub_${customerId.hashCode.abs()}',
        paymentId: 'bypass_pay_${customerId.hashCode.abs()}',
        message: 'Payment bypassed (dev)',
      );
    }

    if (!RazorpayConfig.isConfigured) {
      throw RazorpayNotConfiguredException();
    }

    final checkout = await FunctionsService.instance.call(
      'createEntryPassCheckout',
      data: {'customerId': customerId},
    );
    final subscriptionId = checkout['subscriptionId']?.toString();
    if (subscriptionId == null || subscriptionId.isEmpty) {
      throw RazorpayPaymentException('Razorpay did not return a subscription id.');
    }
    final keyId = checkout['keyId']?.toString();
    if (keyId == null || keyId.isEmpty) {
      throw RazorpayPaymentException('Razorpay did not return a key id.');
    }

    _activeSubscriptionId = subscriptionId;
    _ensureInitialized();
    _pending = Completer<RazorpayPaymentResult>();

    final options = <String, dynamic>{
      'key': keyId,
      'subscription_id': subscriptionId,
      'name': RazorpayConfig.appName,
      'description': 'Monthly membership · ₹199/month',
      'theme': {'color': '#1A1A2E'},
      'notes': {'custId': customerId},
    };

    if (kDebugMode) {
      debugPrint(
        'Razorpay subscription checkout: sub=$subscriptionId test=${RazorpayConfig.isTestMode}',
      );
    }

    _razorpay!.open(options);
    return _pending!.future;
  }

  Future<void> confirmMembership({
    required String paymentId,
    required String subscriptionId,
    required String signature,
  }) async {
    await FunctionsService.instance.call(
      'confirmEntryPassPayment',
      data: {
        'paymentId': paymentId,
        'subscriptionId': subscriptionId,
        'signature': signature,
      },
    );
  }
}

class RazorpayPaymentException implements Exception {
  RazorpayPaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}
