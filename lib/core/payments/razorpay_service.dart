import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vetted_club_mobile/core/config/razorpay_config.dart';

enum RazorpayPaymentStatus { success, cancelled, failed }

class RazorpayPaymentResult {
  const RazorpayPaymentResult({
    required this.status,
    this.message,
    this.orderId,
    this.paymentId,
    this.subscriptionId,
    this.raw,
  });

  final RazorpayPaymentStatus status;
  final String? message;
  final String? orderId;
  final String? paymentId;
  final String? subscriptionId;
  final Map<String, String>? raw;
}

class RazorpayNotConfiguredException implements Exception {
  @override
  String toString() =>
      'Razorpay is not configured. Add RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET to .env';
}

/// Razorpay Subscriptions — ₹199/month via Checkout (`subscription_id`).
///
/// Plan/subscription are created with the API key secret (dev only). Production
/// should move this to your backend.
class RazorpayService {
  RazorpayService._();

  static final RazorpayService instance = RazorpayService._();

  Razorpay? _razorpay;
  Completer<RazorpayPaymentResult>? _pending;
  String? _sessionPlanId;
  String? _activeSubscriptionId;

  Map<String, String> get _authHeaders => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}'))}',
        'Content-Type': 'application/json',
      };

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

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('https://api.razorpay.com$path'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (kDebugMode) {
      debugPrint('Razorpay $path failed: ${response.statusCode} ${response.body}');
    }
    throw RazorpayPaymentException(_messageFromError(response));
  }

  String _messageFromError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      final description = error?['description']?.toString();
      if (description != null && description.isNotEmpty) {
        return description;
      }
    } catch (_) {
      // Fall through to generic message.
    }
    return 'Could not start subscription (${response.statusCode}).';
  }

  Future<String> _resolvePlanId() async {
    final fromEnv = RazorpayConfig.planId;
    if (fromEnv.isNotEmpty) return fromEnv;
    if (_sessionPlanId != null) return _sessionPlanId!;

    final plan = await _post('/v1/plans', {
      'period': 'monthly',
      'interval': 1,
      'item': {
        'name': RazorpayConfig.membershipPlanName,
        'amount': RazorpayConfig.membershipAmountPaise,
        'currency': 'INR',
        'description': '₹199 per month',
      },
    });

    final id = plan['id']?.toString();
    if (id == null || id.isEmpty) {
      throw RazorpayPaymentException('Razorpay did not return a plan id.');
    }
    _sessionPlanId = id;
    if (kDebugMode) {
      debugPrint('Razorpay plan created: $id');
    }
    return id;
  }

  Future<Map<String, dynamic>> _createSubscription({
    required String planId,
    required String customerId,
  }) async {
    return _post('/v1/subscriptions', {
      'plan_id': planId,
      'total_count': RazorpayConfig.subscriptionTotalCount,
      'quantity': 1,
      'customer_notify': 1,
      'notes': {'custId': customerId},
    });
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

    final planId = await _resolvePlanId();
    final subscription = await _createSubscription(
      planId: planId,
      customerId: customerId,
    );

    final subscriptionId = subscription['id']?.toString();
    if (subscriptionId == null || subscriptionId.isEmpty) {
      throw RazorpayPaymentException('Razorpay did not return a subscription id.');
    }

    _activeSubscriptionId = subscriptionId;
    _ensureInitialized();
    _pending = Completer<RazorpayPaymentResult>();

    final options = <String, dynamic>{
      'key': RazorpayConfig.keyId,
      'subscription_id': subscriptionId,
      'name': RazorpayConfig.appName,
      'description': 'Monthly membership · ₹199/month',
      'theme': {'color': '#1A1A2E'},
      'notes': {'custId': customerId},
    };

    if (kDebugMode) {
      debugPrint(
        'Razorpay subscription checkout: sub=$subscriptionId plan=$planId test=${RazorpayConfig.isTestMode}',
      );
    }

    _razorpay!.open(options);
    return _pending!.future;
  }
}

class RazorpayPaymentException implements Exception {
  RazorpayPaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}
