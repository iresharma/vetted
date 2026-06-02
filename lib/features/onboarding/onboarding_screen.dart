import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_button.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_logo_mark.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_chip.dart';
import 'package:vetted_club_mobile/features/auth/phone_auth_screen.dart';
import 'package:vetted_club_mobile/features/onboarding/widgets/onboarding_illustrations.dart';

enum _OnboardingPhase { splash, step1, step2, step3, step4, step5 }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _OnboardingPhase _phase = _OnboardingPhase.splash;
  bool _showSplashText = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showSplashText = true);
    });
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) _goTo(_OnboardingPhase.step1);
    });
  }

  void _goTo(_OnboardingPhase phase) {
    if (phase == _phase) return;
    setState(() => _phase = phase);
  }

  void _next() {
    final next = switch (_phase) {
      _OnboardingPhase.step1 => _OnboardingPhase.step2,
      _OnboardingPhase.step2 => _OnboardingPhase.step3,
      _OnboardingPhase.step3 => _OnboardingPhase.step4,
      _OnboardingPhase.step4 => _OnboardingPhase.step5,
      _ => _phase,
    };
    _goTo(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: AppMotion.slideDuration,
          switchInCurve: AppMotion.standardCurve,
          switchOutCurve: AppMotion.standardCurve,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: switch (_phase) {
            _OnboardingPhase.splash => _SplashView(
                key: const ValueKey('splash'),
                showText: _showSplashText,
              ),
            _OnboardingPhase.step1 => _OnboardingStepView(
                key: const ValueKey('step1'),
                stepIndex: 0,
                gradientColor: AppColors.coral,
                illustration: const OnboardingCardsIllustration(),
                headline: "You've been\nhere before.",
                subtitle: "The apps aren't broken.\nThe intent is.",
                ctaLabel: "That's exactly it →",
                onNext: _next,
                onSkip: () => _goTo(_OnboardingPhase.step5),
              ),
            _OnboardingPhase.step2 => _OnboardingStepView(
                key: const ValueKey('step2'),
                stepIndex: 1,
                gradientColor: AppColors.amber,
                illustration: const OnboardingSignalIllustration(),
                headline: 'The right person\nis in there.',
                subtitle:
                    'Somewhere. Buried under\neveryone who isn\'t serious.',
                ctaLabel: 'So what changed? →',
                onNext: _next,
                onSkip: () => _goTo(_OnboardingPhase.step5),
              ),
            _OnboardingPhase.step3 => _OnboardingStepView(
                key: const ValueKey('step3'),
                stepIndex: 2,
                gradientColor: AppColors.mint,
                illustration: const OnboardingGatesIllustration(),
                headline: 'We made intent\nthe price of entry.',
                subtitle: 'Three gates. No exceptions.',
                headlineSize: 32,
                ctaLabel: "Who's inside? →",
                onNext: _next,
                onSkip: () => _goTo(_OnboardingPhase.step5),
              ),
            _OnboardingPhase.step4 => _OnboardingStepView(
                key: const ValueKey('step4'),
                stepIndex: 3,
                gradientColor: AppColors.violet,
                illustration: const OnboardingMembersIllustration(),
                headline: '847 verified\nmembers.',
                subtitle: 'In Bangalore. Right now.\nAll paid to be here.',
                ctaLabel: "I'm ready →",
                onNext: _next,
                onSkip: () => _goTo(_OnboardingPhase.step5),
              ),
            _OnboardingPhase.step5 => _FinalStepView(
                key: const ValueKey('step5'),
                onGetVerified: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const PhoneAuthScreen(),
                    ),
                  );
                },
              ),
          },
        ),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({super.key, required this.showText});

  final bool showText;

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.9,
                colors: [
                  AppColors.violet.withValues(alpha: 0.09),
                  Colors.transparent,
                ],
                stops: const [0, 0.65],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const VcLogoMark(size: 84, animated: true),
                    const SizedBox(height: 22),
                    AnimatedOpacity(
                      opacity: widget.showText ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedSlide(
                        offset: widget.showText
                            ? Offset.zero
                            : const Offset(0, 0.15),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease,
                        child: Column(
                          children: [
                            Text(
                              'The Vetted Club',
                              textAlign: TextAlign.center,
                              style:
                                  AppTypography.title().copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'MEMBERS ONLY',
                              textAlign: TextAlign.center,
                              style: AppTypography.microLabel(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 100,
                height: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: ColoredBox(
                    color: AppColors.s2,
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-100 + 200 * _shimmer.value, 0),
                          child: Container(
                            width: 100,
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 72),
          ],
        ),
      ],
    );
  }
}

class _OnboardingStepView extends StatelessWidget {
  const _OnboardingStepView({
    super.key,
    required this.stepIndex,
    required this.gradientColor,
    required this.illustration,
    required this.headline,
    required this.subtitle,
    required this.ctaLabel,
    required this.onNext,
    required this.onSkip,
    this.headlineSize = 36,
  });

  final int stepIndex;
  final Color gradientColor;
  final Widget illustration;
  final String headline;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final double headlineSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  gradientColor.withValues(alpha: stepIndex == 0 ? 0.08 : 0.06),
                  Colors.transparent,
                ],
                stops: const [0, 0.55],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Skip',
                    style: AppTypography.microLabel().copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 56,
              child: Center(child: illustration),
            ),
            Expanded(
              flex: 44,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: AppTypography.display().copyWith(
                              fontSize: headlineSize,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: AppTypography.body(
                              color: AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w400,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    VcButton(
                      label: ctaLabel,
                      size: VcButtonSize.large,
                      expanded: true,
                      onTap: onNext,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label, required this.variant});

  final String label;
  final VcChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = switch (variant) {
      VcChipVariant.mint => AppColors.mint,
      VcChipVariant.amber => AppColors.amber,
      _ => AppColors.violet,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✓',
            style: AppTypography.chip(color: color).copyWith(fontSize: 9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.supporting(color: color).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalStepView extends StatelessWidget {
  const _FinalStepView({super.key, required this.onGetVerified});

  final VoidCallback onGetVerified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 1.1,
                colors: [
                  AppColors.violet.withValues(alpha: 0.11),
                  Colors.transparent,
                ],
                stops: const [0, 0.65],
              ),
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 52),
            const Expanded(child: Center(child: OnboardingOrbitIllustration())),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 52),
              child: Column(
                children: [
                  Text(
                    'This is\ndifferent.',
                    textAlign: TextAlign.center,
                    style: AppTypography.display().copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No noise. Just people\nwho are actually here.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.textSecondary)
                        .copyWith(fontWeight: FontWeight.w400, height: 1.7),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _TrustChip(
                        label: 'Real identity',
                        variant: VcChipVariant.mint,
                      ),
                      _TrustChip(
                        label: 'Intent filter',
                        variant: VcChipVariant.amber,
                      ),
                      _TrustChip(
                        label: 'Active members',
                        variant: VcChipVariant.violet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  VcButton(
                    label: 'Let\'s get you in →',
                    size: VcButtonSize.large,
                    expanded: true,
                    onTap: onGetVerified,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Refundable if verification fails',
                    textAlign: TextAlign.center,
                    style: AppTypography.supporting(color: AppColors.textMuted)
                        .copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
