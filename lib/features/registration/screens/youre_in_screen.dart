import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/config/razorpay_config.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/neopop/neopop_pressable.dart';

class YoureInScreen extends StatefulWidget {
  const YoureInScreen({super.key, required this.onBuildBiodata});

  final VoidCallback onBuildBiodata;

  @override
  State<YoureInScreen> createState() => _YoureInScreenState();
}

class _YoureInScreenState extends State<YoureInScreen>
    with SingleTickerProviderStateMixin {
  static const _memberCount = '347';
  static const _city = 'Bangalore';

  static const _confettiColors = [
    AppColors.violet,
    AppColors.mint,
    AppColors.amber,
    AppColors.coral,
  ];

  late final ConfettiController _confetti;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
      duration: const Duration(milliseconds: 1800),
    );
    _entrance = AnimationController(
      vsync: this,
      duration: AppMotion.slideDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entrance.forward();
      _burstConfetti();
      HapticFeedback.mediumImpact();
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _burstConfetti();
      });
    });
  }

  void _burstConfetti() => _confetti.play();

  @override
  void dispose() {
    _confetti.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passLabel =
        '₹${RazorpayConfig.membershipAmountInr.split('.').first} Verification Pass';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: _CelebrationGlow()),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.045,
                    numberOfParticles: 14,
                    maxBlastForce: 22,
                    minBlastForce: 10,
                    gravity: 0.12,
                    particleDrag: 0.05,
                    colors: _confettiColors,
                    minimumSize: const Size(6, 4),
                    maximumSize: const Size(11, 7),
                    canvas: Size(
                      MediaQuery.sizeOf(context).width,
                      MediaQuery.sizeOf(context).height * 0.55,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entrance,
                        curve: AppMotion.standardCurve,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _entrance,
                          curve: AppMotion.standardCurve,
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _StatsHeader(
                              memberCount: _memberCount,
                              city: _city,
                            ),
                            const SizedBox(height: 36),
                            Text(
                              'You did what\nmost won\'t.',
                              style: AppTypography.display().copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w500,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Two gates. Real identity. Actual intent.\n'
                              'The algorithm is paying attention.',
                              style: AppTypography.body(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 15, height: 1.65),
                            ),
                            const SizedBox(height: 32),
                            _GateStep(
                              state: _GateStepState.done,
                              accent: AppColors.mint,
                              title: passLabel,
                              detail: 'Intent confirmed. Paid.',
                            ),
                            const SizedBox(height: 22),
                            const _GateStep(
                              state: _GateStepState.done,
                              accent: AppColors.violet,
                              title: 'Aadhaar via DigiLocker',
                              detail: 'Real person. Real age. Locked.',
                            ),
                            const SizedBox(height: 22),
                            const _GateStep(
                              state: _GateStepState.done,
                              accent: AppColors.mint,
                              title: 'Membership activated',
                              detail:
                                  'Daily 5 unlocked at profile completion.',
                            ),
                            const SizedBox(height: 22),
                            const _GateStep(
                              state: _GateStepState.next,
                              accent: AppColors.coral,
                              title: 'Build your biodata',
                              detail:
                                  '5 levels · ~5 mins · no forms, we promise.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LetsGoButton(
                          onTap: () {
                            _burstConfetti();
                            widget.onBuildBiodata();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      _InfoButton(
                        onTap: () => _showAboutGates(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutGates(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.s1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Why two gates?', style: AppTypography.title()),
              const SizedBox(height: 10),
              Text(
                'Paid membership, government ID, and an active sub keep the pool '
                'serious. Everyone you see cleared the same bar.',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CelebrationGlow extends StatelessWidget {
  const _CelebrationGlow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: 380,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.15,
              colors: [
                AppColors.violet.withValues(alpha: 0.12),
                AppColors.coral.withValues(alpha: 0.04),
                Colors.transparent,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.memberCount,
    required this.city,
  });

  final String memberCount;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memberCount,
                style: AppTypography.display(color: AppColors.violet).copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'MEMBERS IN BLR',
                style: AppTypography.microLabel(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r10,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: AppTypography.body().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'YOUR CIRCLE',
                style: AppTypography.microLabel(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _GateStepState { done, next }

class _GateStep extends StatelessWidget {
  const _GateStep({
    required this.accent,
    required this.title,
    required this.detail,
    this.state = _GateStepState.done,
  });

  final _GateStepState state;
  final Color accent;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final done = state == _GateStepState.done;
    final isNext = state == _GateStepState.next;
    final detailColor = done
        ? accent
        : isNext
            ? accent.withValues(alpha: 0.88)
            : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GateIcon(
          done: done,
          accent: accent,
          isNext: isNext,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body().copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: AppTypography.supporting(color: detailColor).copyWith(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GateIcon extends StatelessWidget {
  const _GateIcon({
    required this.done,
    required this.accent,
    this.isNext = false,
  });

  final bool done;
  final bool isNext;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: done
            ? accent
            : isNext
                ? AppColors.coralDim
                : AppColors.s2,
        shape: BoxShape.circle,
        border: done
            ? null
            : Border.all(
                color: accent.withValues(alpha: isNext ? 0.42 : 0.55),
                width: 1.5,
              ),
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(
              Icons.check_rounded,
              size: 22,
              color: AppColors.bg,
            )
          : Icon(
              Icons.all_inclusive_rounded,
              size: 22,
              color: accent.withValues(alpha: isNext ? 0.95 : 1),
            ),
    );
  }
}

class _LetsGoButton extends StatelessWidget {
  const _LetsGoButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoPopPressable(
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
          height: 56,
          child: Center(
            child: Text(
              'Let\'s go →',
              style: AppTypography.button(color: AppColors.textPrimary)
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoPopPressable(
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
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.info_outline_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
