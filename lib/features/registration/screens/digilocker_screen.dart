import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/config/razorpay_config.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_gate_header.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

enum _DigiPhase { idle, verifying, verified }

class DigilockerScreen extends StatefulWidget {
  const DigilockerScreen({super.key, required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<DigilockerScreen> createState() => _DigilockerScreenState();
}

class _DigilockerScreenState extends State<DigilockerScreen>
    with TickerProviderStateMixin {
  static const _confettiColors = [
    AppColors.violet,
    AppColors.mint,
    AppColors.amber,
  ];

  _DigiPhase _phase = _DigiPhase.idle;
  late final AnimationController _shimmer;
  final ConfettiController _confetti = ConfettiController(
    duration: Duration(milliseconds: 1200),
  );
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _confetti.dispose();
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _startVerification() {
    if (_phase != _DigiPhase.idle) return;

    setState(() => _phase = _DigiPhase.verifying);
    _shimmer.repeat();

    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _shimmer.stop();
      setState(() => _phase = _DigiPhase.verified);
      if (mounted) {
        _confetti.play();
        HapticFeedback.mediumImpact();
      }
      _advanceTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) widget.onVerified();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final verifying = _phase == _DigiPhase.verifying;
    final verified = _phase == _DigiPhase.verified;
    final passLabel =
        '₹${RazorpayConfig.membershipAmountInr.split('.').first} PASS';

    return RegistrationScaffold(
      scrollBody: false,
      bodyPadding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      footerPadding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      header: const RegistrationGateHeader(currentGateIndex: 1),
      footerCaption:
          verified ? null : 'REDIRECTS TO DIGILOCKER · RETURNS AUTOMATICALLY',
      cta: _VerifyCta(
        label: verified
            ? 'Continuing…'
            : verifying
                ? 'Verifying…'
                : 'Verify with DigiLocker',
        enabled: !verifying && !verified,
        showFingerprint: !verified,
        onTap: _startVerification,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: AppMotion.slideDuration,
            switchInCurve: AppMotion.standardCurve,
            child: verified
                ? _VerifiedSuccessBody(
                    key: const ValueKey('verified'),
                    passLabel: passLabel,
                  )
                : _DigiFormBody(
                    key: const ValueKey('form'),
                    passLabel: passLabel,
                    phase: _phase,
                    shimmer: _shimmer,
                  ),
          ),
          if (verified)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 10,
                    maxBlastForce: 16,
                    minBlastForce: 8,
                    gravity: 0.14,
                    colors: _confettiColors,
                    minimumSize: const Size(5, 4),
                    maximumSize: const Size(9, 6),
                    canvas: Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DigiFormBody extends StatelessWidget {
  const _DigiFormBody({
    super.key,
    required this.passLabel,
    required this.phase,
    required this.shimmer,
  });

  final String passLabel;
  final _DigiPhase phase;
  final AnimationController shimmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        Text(
          'Prove you\'re real.',
          style: AppTypography.display().copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.55,
            ),
            children: [
              const TextSpan(
                text:
                    'Your name and age come straight from government records. ',
              ),
              TextSpan(
                text: 'Never stored.',
                style: AppTypography.body(color: AppColors.mint).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        RegistrationGateMilestones(
          passLabel: passLabel,
          currentGateIndex: 1,
        ),
        const SizedBox(height: 18),
        _DigiDetailsCard(phase: phase, shimmer: shimmer),
        if (phase == _DigiPhase.idle) ...[
          const SizedBox(height: 10),
          const _UnlockHintCard(),
        ],
      ],
    );
  }
}

class _VerifiedSuccessBody extends StatelessWidget {
  const _VerifiedSuccessBody({
    super.key,
    required this.passLabel,
  });

  final String passLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14),
        Text(
          'Identity locked.',
          style: AppTypography.display().copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Real name and age are on your profile. Aadhaar was never stored.',
          style: AppTypography.body(color: AppColors.textSecondary).copyWith(
            fontSize: 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        RegistrationGateMilestones(
          passLabel: passLabel,
          currentGateIndex: 1,
          identityVerified: true,
        ),
        const SizedBox(height: 18),
        const _VerifiedSuccessCard(),
      ],
    );
  }
}

class _VerifiedSuccessCard extends StatelessWidget {
  const _VerifiedSuccessCard();

  @override
  Widget build(BuildContext context) {
    return VcNeoPopCard(
      accent: AccentColor.mint,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                size: 28,
                color: AppColors.bg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gate 2 cleared',
                    style: AppTypography.body().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Both gates down. Taking you to the club…',
                    style: AppTypography.supporting(color: AppColors.mint)
                        .copyWith(fontSize: 14, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DigiDetailsCard extends StatelessWidget {
  const _DigiDetailsCard({
    required this.phase,
    required this.shimmer,
  });

  final _DigiPhase phase;
  final AnimationController shimmer;

  @override
  Widget build(BuildContext context) {
    final verifying = phase == _DigiPhase.verifying;

    return VcSoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.amberDim,
                  borderRadius: AppRadius.r12,
                  border: Border.all(color: AppColors.amber, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text('🏛', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DigiLocker',
                      style: AppTypography.body().copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ministry of Electronics & IT · Govt. of India',
                      style:
                          AppTypography.supporting(color: AppColors.textMuted)
                              .copyWith(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (verifying) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: AnimatedBuilder(
                  animation: shimmer,
                  builder: (context, child) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: AppColors.s3),
                        FractionallySizedBox(
                          widthFactor: 0.35,
                          alignment: Alignment(-1 + 2 * shimmer.value, 0),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.violet,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Talking to government records…',
              style: AppTypography.supporting(color: AppColors.textMuted),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const _FeatureRow(
              accent: AppColors.mint,
              text: 'Real name from Aadhaar — shown on your profile.',
            ),
            const SizedBox(height: 10),
            const _FeatureRow(
              accent: AppColors.violet,
              text: 'Age locked. Can\'t be edited after this.',
            ),
            const SizedBox(height: 10),
            const _FeatureRow(
              accent: AppColors.textMuted,
              text: 'We never store your Aadhaar number.',
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.accent,
    required this.text,
  });

  final Color accent;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnlockHintCard extends StatelessWidget {
  const _UnlockHintCard();

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text.rich(
        TextSpan(
          style: AppTypography.body(color: AppColors.textSecondary).copyWith(
            fontSize: 13,
            height: 1.45,
          ),
          children: [
            const TextSpan(text: 'Finish this gate → '),
            TextSpan(
              text: 'membership goes live',
              style: AppTypography.body(color: AppColors.mint).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const TextSpan(text: ' · Daily 5 unlocks after biodata.'),
          ],
        ),
      ),
    );
  }
}

class _VerifyCta extends StatelessWidget {
  const _VerifyCta({
    required this.label,
    required this.enabled,
    this.showFingerprint = true,
    this.onTap,
  });

  final String label;
  final bool enabled;
  final bool showFingerprint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoPopPressable(
      enabled: enabled,
      onTap: onTap,
      shadowColor: AppColors.s4,
      borderRadius: AppRadius.r12,
      idleShadowOffset: 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: AppColors.textPrimary.withValues(alpha: 0.85),
            width: 1.5,
          ),
        ),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showFingerprint) ...[
                Icon(
                  Icons.fingerprint_rounded,
                  size: 22,
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: AppTypography.button(
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
