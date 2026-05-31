import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/auth_errors.dart';
import 'package:vetted_club_mobile/core/services/auth_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/auth/otp_verify_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _phoneValid => _phoneDigits.length == 10;

  Future<void> _sendCode() async {
    if (!_phoneValid || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      AuthService.instance.resetVerification();
      await AuthService.instance.sendOtp(_phoneDigits);
      if (!mounted) return;
      setState(() => _loading = false);
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerifyScreen(phoneDigits: _phoneDigits),
        ),
      );
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
                    Text(
                      "Let's get started",
                      style: AppTypography.eyebrow(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Enter your\nnumber.',
                      style: AppTypography.display().copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No passwords. No nonsense.\nOne OTP and you\'re in.',
                      style: AppTypography.body(color: AppColors.textSecondary)
                          .copyWith(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 40),
                    VcPhoneInput(
                      controller: _phoneController,
                      onChanged: (_) => setState(() => _error = null),
                      autofocus: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: AppTypography.supporting(color: AppColors.coral)
                            .copyWith(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Encrypted · Powered by Razorpay',
                      style: AppTypography.supporting(color: AppColors.textMuted)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 48 + bottomInset),
              child: VcButton(
                label: _loading ? 'Sending…' : 'Send code →',
                size: VcButtonSize.large,
                expanded: true,
                enabled: _phoneValid && !_loading,
                onTap: _phoneValid && !_loading ? _sendCode : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
