import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/config/razorpay_config.dart';
import 'package:vetted_club_mobile/core/payments/razorpay_service.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_gate_header.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class EntryPassScreen extends StatefulWidget {
  const EntryPassScreen({
    super.key,
    required this.customerId,
    required this.onContinue,
  });

  final String customerId;
  final VoidCallback onContinue;

  @override
  State<EntryPassScreen> createState() => _EntryPassScreenState();
}

class _EntryPassScreenState extends State<EntryPassScreen> {
  bool _paying = false;

  void _completeMembership(RazorpayPaymentResult result) {
    final razorpaySubId = result.subscriptionId;
    if (razorpaySubId != null && razorpaySubId.isNotEmpty) {
      RegistrationService.instance.saveSubscription(
        widget.customerId,
        MembershipSubscription(
          subscriptionId: razorpaySubId,
          orderId: result.paymentId ?? result.orderId ?? '',
          amountInr: RazorpayConfig.membershipAmountInr,
          frequencyUnit: 'MONTH',
          startedAt: DateTime.now(),
        ),
      );
    }
    widget.onContinue();
  }

  Future<void> _beginMembership() async {
    if (_paying) return;

    setState(() => _paying = true);

    try {
      final result = await RazorpayService.instance.payMembership(
        customerId: widget.customerId,
      );

      if (!mounted) return;

      switch (result.status) {
        case RazorpayPaymentStatus.success:
          _completeMembership(result);
        case RazorpayPaymentStatus.cancelled:
          _showMessage(result.message ?? 'Payment cancelled.');
        case RazorpayPaymentStatus.failed:
          _showMessage(result.message ?? 'Payment was not completed.');
      }
    } on RazorpayNotConfiguredException {
      if (!mounted) return;
      _showMessage(
        'Razorpay is not configured. Add RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET to .env and restart.',
      );
    } on RazorpayPaymentException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: AppTypography.supporting(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.s3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      header: const RegistrationGateHeader(currentGateIndex: 0),
      ctaLabel: _paying ? 'Opening checkout…' : 'Begin membership',
      ctaIcon: Icons.credit_card_rounded,
      ctaIconPosition: VcButtonIconPosition.leading,
      ctaEnabled: RazorpayConfig.isConfigured || RazorpayConfig.bypassPayment,
      ctaLoading: _paying,
      onCta: _beginMembership,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A standard\nworth keeping.',
            style: AppTypography.display().copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Membership is ₹199 a month, enough to mean something, '
            'light enough to leave when you\'re done.',
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),
          const VcSoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _BenefitRow(
                  dotColor: AppColors.violet,
                  title: '₹199/month',
                  detail: 'Cancel anytime',
                ),
                Divider(height: 0.5, color: AppColors.border),
                _BenefitRow(
                  dotColor: AppColors.mint,
                  title: 'Identity locked',
                  detail: 'Real name + age',
                ),
                Divider(height: 0.5, color: AppColors.border),
                _BenefitRow(
                  dotColor: AppColors.amber,
                  title: 'Fair refund',
                  detail: 'If verification fails',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _MembershipPrice(),
          const SizedBox(height: 8),
          Text(
            RazorpayConfig.isTestMode
                ? 'Secured by Razorpay · Test mode · No lock-in'
                : 'Secured by Razorpay · No lock-in',
            textAlign: TextAlign.center,
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 12),
          ),
          if (RazorpayConfig.bypassPayment) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _paying ? null : _beginMembership,
              child: Text(
                'Skip payment (dev bypass)',
                style: AppTypography.supporting(color: AppColors.textMuted)
                    .copyWith(
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          if (!RazorpayConfig.isConfigured &&
              !RazorpayConfig.bypassPayment) ...[
            const SizedBox(height: 12),
            Text(
              'Add RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET to .env to enable payments.',
              textAlign: TextAlign.center,
              style: AppTypography.supporting(color: AppColors.coral)
                  .copyWith(fontSize: 11, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _MembershipPrice extends StatelessWidget {
  const _MembershipPrice();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '₹199',
          textAlign: TextAlign.center,
          style: AppTypography.price(fontSize: 40),
        ),
        const SizedBox(height: 4),
        Text(
          'per month',
          textAlign: TextAlign.center,
          style:
              AppTypography.supporting(color: AppColors.textSecondary).copyWith(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.02 * 14,
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.dotColor,
    required this.title,
    required this.detail,
  });

  final Color dotColor;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTypography.body().copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            detail,
            style: AppTypography.supporting(color: AppColors.textSecondary)
                .copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
