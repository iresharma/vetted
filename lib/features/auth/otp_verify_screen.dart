import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/auth_errors.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.phoneDigits});

  final String phoneDigits;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpKey = GlobalKey<VcOtpInputRowState>();
  String _otp = '';
  bool _loading = false;
  bool _verifyInFlight = false;
  String? _error;
  int _resendSeconds = 42;
  Timer? _resendTimer;

  String get _formattedPhone {
    final digits = widget.phoneDigits;
    if (digits.length < 10) return '+91 $digits';
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }

  bool get _otpValid => _otp.length == 6;

  bool get _canResend => _resendSeconds <= 0 && !_loading;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 42);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _resendLabel {
    if (_loading && _otp.isEmpty) return 'Sending…';
    if (_canResend) return 'Resend code';
    final m = _resendSeconds ~/ 60;
    final s = _resendSeconds % 60;
    return 'Resend in $m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify([String? code]) async {
    final token = code ?? _otpKey.currentState?.value ?? _otp;
    if (token.length != 6 || _verifyInFlight) return;

    _verifyInFlight = true;
    setState(() {
      _otp = token;
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.verifyOtp(token: token);
      // AuthGate routes to RegistrationFlowScreen when signed in.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _otpKey.currentState?.clear();
      setState(() {
        _otp = '';
        _error = AuthErrors.verifyOtp(e);
      });
    } catch (e) {
      if (!mounted) return;
      _otpKey.currentState?.clear();
      setState(() {
        _otp = '';
        _error = AuthErrors.fromException(e);
      });
    } finally {
      _verifyInFlight = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.sendOtp(widget.phoneDigits);
      if (!mounted) return;
      _otpKey.currentState?.clear();
      setState(() {
        _otp = '';
        _loading = false;
      });
      _startResendTimer();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AuthErrors.sendOtp(e);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AuthErrors.fromException(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed:
                            _loading ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '← Change number',
                          style: AppTypography.supporting(color: AppColors.violet)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your\nmessages.',
                      style: AppTypography.display().copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.body(color: AppColors.textSecondary)
                            .copyWith(fontSize: 14),
                        children: [
                          const TextSpan(text: 'Sent to '),
                          TextSpan(
                            text: _formattedPhone,
                            style: AppTypography.body().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: VcOtpInputRow(
                        key: _otpKey,
                        autofocus: true,
                        onChanged: (value) => setState(() {
                          _otp = value;
                          if (value.length < 6) _verifyInFlight = false;
                          _error = null;
                        }),
                        onCompleted: _verify,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppTypography.supporting(color: AppColors.coral)
                            .copyWith(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Center(
                      child: TextButton(
                        onPressed: _canResend ? _resend : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _resendLabel,
                          style: AppTypography.supporting(
                            color: _canResend
                                ? AppColors.violet
                                : AppColors.textMuted,
                          ).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 48 + bottomInset),
              child: VcButton(
                label: _loading ? 'Verifying…' : 'Verify →',
                size: VcButtonSize.large,
                expanded: true,
                enabled: _otpValid && !_loading,
                onTap: _otpValid && !_loading ? _verify : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
