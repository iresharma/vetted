import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_chip.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_logo_mark.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_trust_badge.dart';

// ── Step 1: Swipe cards ──────────────────────────────────────────────────────

class OnboardingCardsIllustration extends StatefulWidget {
  const OnboardingCardsIllustration({super.key});

  @override
  State<OnboardingCardsIllustration> createState() =>
      _OnboardingCardsIllustrationState();
}

class _OnboardingCardsIllustrationState
    extends State<OnboardingCardsIllustration> {
  int _flownCount = 0;
  final _xMarks = <_XMark>[];

  static const _cards = [
    _StackCard(initials: 'VG', top: 56, left: 16, rotation: -3, opacity: 0.35),
    _StackCard(initials: 'NJ', top: 42, left: 10, rotation: 7, opacity: 0.5),
    _StackCard(initials: 'AM', top: 28, left: 6, rotation: -2, opacity: 0.65),
    _StackCard(initials: 'RS', top: 14, left: 4, rotation: 4, opacity: 0.8),
    _StackCard(
      initials: 'PK',
      top: 0,
      left: 0,
      rotation: -6,
      opacity: 1,
      isFront: true,
    ),
  ];

  static const _passButtonCenter = Offset(48, 128);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800), _flyNext);
  }

  void _flyNext() {
    if (_flownCount >= 3 || !mounted) return;

    final card = _cards[_cards.length - 1 - _flownCount];

    setState(() {
      _xMarks.add(_XMark(
        left: card.left + _passButtonCenter.dx,
        top: card.top + _passButtonCenter.dy,
      ));
      _flownCount++;
    });

    if (_flownCount < 3) {
      Future<void>.delayed(const Duration(milliseconds: 700), _flyNext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 160,
          height: 210,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < _cards.length; i++)
                _FlyingCard(
                  key: ValueKey(_cards[i].initials),
                  card: _cards[i],
                  indexFromFront: _cards.length - 1 - i,
                  flown: i >= _cards.length - _flownCount,
                ),
              for (final mark in _xMarks)
                _XMarkWidget(key: ValueKey('${mark.left}-${mark.top}'), mark: mark),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.s2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '2 years of swiping',
                  style: AppTypography.microLabel(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StackCard {
  const _StackCard({
    required this.initials,
    required this.top,
    required this.left,
    required this.rotation,
    required this.opacity,
    this.isFront = false,
  });

  final String initials;
  final double top;
  final double left;
  final double rotation;
  final double opacity;
  final bool isFront;
}

class _FlyingCard extends StatelessWidget {
  const _FlyingCard({
    super.key,
    required this.card,
    required this.indexFromFront,
    required this.flown,
  });

  final _StackCard card;
  final int indexFromFront;
  final bool flown;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${card.initials}-$flown'),
      tween: Tween(begin: 0.0, end: flown ? 1.0 : 0.0),
      duration: flown ? const Duration(milliseconds: 500) : Duration.zero,
      curve: Curves.ease,
      builder: (context, t, child) {
        final flyOffset = Offset(0, -110 * t);
        final flyRotation = card.rotation + 16 * t;
        final scale = 1 - 0.28 * t;
        final opacity = card.opacity * (1 - t);

        return Positioned(
          top: card.top + flyOffset.dy,
          left: card.left,
          child: Transform.rotate(
            angle: flyRotation * math.pi / 180,
            child: Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity.clamp(0, 1), child: child),
            ),
          ),
        );
      },
      child: _ProfileMiniCard(
        initials: card.initials,
        isFront: card.isFront,
      ),
    );
  }
}

class _ProfileMiniCard extends StatelessWidget {
  const _ProfileMiniCard({
    required this.initials,
    this.isFront = false,
  });

  final String initials;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 185,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1428),
        borderRadius: AppRadius.r16,
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: isFront
            ? const [
                BoxShadow(
                  color: Color(0x99000000),
                  blurRadius: 40,
                  offset: Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AvatarBox(initials: initials),
          if (isFront) ...[
            const SizedBox(height: 8),
            Container(
              width: 76,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.s3,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.s3.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.s2,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '✕',
                    style: AppTypography.supporting(color: AppColors.textMuted)
                        .copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '♥',
                    style: AppTypography.supporting().copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarBox extends StatelessWidget {
  const _AvatarBox({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.s3,
        borderRadius: AppRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.compactTitle(color: AppColors.textSecondary)
            .copyWith(fontSize: 16),
      ),
    );
  }
}

class _XMark {
  const _XMark({
    required this.left,
    required this.top,
  });

  final double left;
  final double top;
}

class _XMarkWidget extends StatefulWidget {
  const _XMarkWidget({super.key, required this.mark});

  final _XMark mark;

  @override
  State<_XMarkWidget> createState() => _XMarkWidgetState();
}

class _XMarkWidgetState extends State<_XMarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.mark.left - 14,
      top: widget.mark.top - 14,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: AppMotion.popCurve,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedBuilder(
          animation: _float,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -6 * _float.value),
              child: child,
            );
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.coralDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.coral, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '✕',
              style: AppTypography.supporting(color: AppColors.coral)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Signal in noise ──────────────────────────────────────────────────

class OnboardingSignalIllustration extends StatefulWidget {
  const OnboardingSignalIllustration({super.key});

  @override
  State<OnboardingSignalIllustration> createState() =>
      _OnboardingSignalIllustrationState();
}

class _OnboardingSignalIllustrationState
    extends State<OnboardingSignalIllustration>
    with TickerProviderStateMixin {
  late AnimationController _pulse1;
  late AnimationController _pulse2;
  late AnimationController _ripple;
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _pulse1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulse2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    )..repeat(reverse: true);
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse1.dispose();
    _pulse2.dispose();
    _ripple.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...List.generate(32, (i) {
            final x = 8 + (i * 23.7) % 84;
            final y = 4 + (i * 17.3) % 86;
            final s = 10.0 + (i % 4) * 7;
            final opacity = 0.06 + (i % 4) * 0.05;
            return Positioned(
              left: 260 * x / 100,
              top: 240 * y / 100,
              child: _FloatingNoiseDot(
                size: s,
                opacity: opacity,
                controller: _float,
                delay: i * 55,
              ),
            );
          }),
          Positioned(
            top: 8,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.s2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(
                'everyone who isn\'t serious',
                style: AppTypography.labelCaps().copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _PulseRing(controller: _pulse1, size: 40, opacity: 0.15),
                  _PulseRing(controller: _pulse2, size: 70, opacity: 0.1),
                  _PulseRing(controller: _pulse2, size: 100, opacity: 0.06),
                  ...List.generate(2, (i) {
                    return AnimatedBuilder(
                      animation: _ripple,
                      builder: (context, child) {
                        final t = (_ripple.value + i * 0.5) % 1.0;
                        return Transform.scale(
                          scale: 0.6 + t * 1.6,
                          child: Opacity(
                            opacity: (0.3 * (1 - t)).clamp(0.0, 1.0),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.violet,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _MatchAvatar(
                    letter: 'A',
                    color: AppColors.violet,
                    bg: const Color(0xFF1E1428),
                  ),
                  const SizedBox(width: 4),
                  const _MatchConnector(),
                  const SizedBox(width: 4),
                  _MatchAvatar(
                    letter: 'B',
                    color: AppColors.mint,
                    bg: const Color(0xFF14181E),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchConnector extends StatelessWidget {
  const _MatchConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.violet, AppColors.mint],
              ),
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'match',
            textAlign: TextAlign.center,
            style: AppTypography.chip(color: AppColors.violet).copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: 0.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNoiseDot extends StatelessWidget {
  const _FloatingNoiseDot({
    required this.size,
    required this.opacity,
    required this.controller,
    required this.delay,
  });

  final double size;
  final double opacity;
  final AnimationController controller;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * controller.value),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.s3.withValues(alpha: opacity),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: size > 18
            ? Center(
                child: Container(
                  width: size * 0.38,
                  height: size * 0.38,
                  decoration: const BoxDecoration(
                    color: AppColors.s4,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.controller,
    required this.size,
    required this.opacity,
  });

  final AnimationController controller;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + controller.value * 0.08,
          child: Opacity(
            opacity: opacity + controller.value * (opacity * 1.5),
            child: child,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.violet),
        ),
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  const _MatchAvatar({
    required this.letter,
    required this.color,
    required this.bg,
  });

  final String letter;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.r10,
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 20,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTypography.compactTitle(color: color).copyWith(fontSize: 14),
      ),
    );
  }
}

// ── Step 3: Gates ────────────────────────────────────────────────────────────

class OnboardingGatesIllustration extends StatefulWidget {
  const OnboardingGatesIllustration({super.key});

  @override
  State<OnboardingGatesIllustration> createState() =>
      _OnboardingGatesIllustrationState();
}

class _OnboardingGatesIllustrationState
    extends State<OnboardingGatesIllustration> {
  int _openCount = 0;
  bool _showPool = false;

  static const _gates = [
    _GateData(
      icon: '◈',
      label: '₹199 membership',
      sub: 'Per month. Cancel anytime.',
      color: AppColors.amber,
      glow: Color(0x33E8A945),
    ),
    _GateData(
      icon: '✓',
      label: 'Aadhaar verified',
      sub: 'Real name. Real age. Locked.',
      color: AppColors.mint,
      glow: Color(0x334AE0A0),
    ),
    _GateData(
      icon: '◉',
      label: 'Active membership',
      sub: 'Stop paying = you leave.',
      color: AppColors.violet,
      glow: Color(0x337C6AF5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 0; i < _gates.length; i++) {
      await Future<void>.delayed(Duration(milliseconds: 500 + i * 600));
      if (!mounted) return;
      setState(() => _openCount = i + 1);
      if (i == 2) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted) setState(() => _showPool = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _gates.length; i++) ...[
            _GateRow(gate: _gates[i], isOpen: i < _openCount),
            if (i < _gates.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 2,
                height: 12,
                color: i < _openCount ? AppColors.violet : AppColors.s3,
              ),
          ],
          AnimatedOpacity(
            opacity: _showPool ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 2,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.violet.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                VcChip(
                  label: 'verified member pool',
                  variant: VcChipVariant.violet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GateData {
  const _GateData({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.glow,
  });

  final String icon;
  final String label;
  final String sub;
  final Color color;
  final Color glow;
}

class _GateRow extends StatelessWidget {
  const _GateRow({required this.gate, required this.isOpen});

  final _GateData gate;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: AppMotion.standardCurve,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: isOpen ? gate.color.withValues(alpha: 0.14) : AppColors.s2,
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: isOpen ? gate.color : AppColors.border,
          width: isOpen ? 1 : 1,
        ),
        boxShadow: isOpen
            ? [
                BoxShadow(color: gate.glow, blurRadius: 24, offset: const Offset(0, 6)),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: AppMotion.popCurve,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOpen ? gate.color : AppColors.s3,
              borderRadius: AppRadius.r10,
            ),
            alignment: Alignment.center,
            child: Text(
              gate.icon,
              style: TextStyle(
                fontSize: 16,
                color: isOpen ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gate.label,
                  style: AppTypography.compactTitle(
                    color: isOpen ? AppColors.textPrimary : AppColors.textMuted,
                  ).copyWith(fontSize: 14),
                ),
                Text(
                  gate.sub,
                  style: AppTypography.supporting(color: AppColors.textMuted)
                      .copyWith(
                    fontSize: 11,
                    color: isOpen ? gate.color : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isOpen ? gate.color : AppColors.textMuted,
            ),
            child: Text(isOpen ? '✓' : '○'),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Member count ─────────────────────────────────────────────────────

class OnboardingMembersIllustration extends StatefulWidget {
  const OnboardingMembersIllustration({super.key});

  @override
  State<OnboardingMembersIllustration> createState() =>
      _OnboardingMembersIllustrationState();
}

class _OnboardingMembersIllustrationState
    extends State<OnboardingMembersIllustration> {
  int _count = 0;
  int _visibleCards = 0;

  static const _members = [
    (
      initials: 'PM',
      bg: Color(0xFF1E1428),
      title: 'Product Designer',
      company: 'Flipkart',
      badge: 'Elite',
      variant: VcTrustBadgeVariant.amber,
    ),
    (
      initials: 'KR',
      bg: Color(0xFF14181E),
      title: 'Investment Analyst',
      company: 'Sequoia',
      badge: 'Highly Trusted',
      variant: VcTrustBadgeVariant.violet,
    ),
    (
      initials: 'AS',
      bg: Color(0xFF1A1410),
      title: 'Co-founder',
      company: 'IIT Bombay',
      badge: 'Trusted',
      variant: VcTrustBadgeVariant.mint,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 400), _tick);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _count = math.min(_count + math.max(2, ((_countTarget - _count) * 0.09).ceil()), _countTarget);
    });
    if (_count < _countTarget) {
      Future<void>.delayed(const Duration(milliseconds: 24), _tick);
    } else {
      _revealCards();
    }
  }

  static const _countTarget = 847;

  Future<void> _revealCards() async {
    for (var i = 0; i < _members.length; i++) {
      await Future<void>.delayed(Duration(milliseconds: 100 + i * 110));
      if (mounted) setState(() => _visibleCards = i + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 168,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.violetDim,
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _count.toString(),
                      style: AppTypography.display(color: AppColors.violet)
                          .copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        letterSpacing: -2.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'verified members · Bangalore',
                textAlign: TextAlign.center,
                style: AppTypography.statCaption(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _members.length; i++)
            AnimatedSlide(
              offset: i < _visibleCards ? Offset.zero : const Offset(0, 0.15),
              duration: const Duration(milliseconds: 400),
              curve: Curves.ease,
              child: AnimatedOpacity(
                opacity: i < _visibleCards ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MemberRow(member: _members[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final ({
    String initials,
    Color bg,
    String title,
    String company,
    String badge,
    VcTrustBadgeVariant variant,
  }) member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: AppRadius.r12,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: member.bg,
              borderRadius: AppRadius.r8,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              member.initials,
              style: AppTypography.compactTitle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.title,
                  style: AppTypography.compactTitle(),
                ),
                Text(
                  member.company,
                  style: AppTypography.supporting(color: AppColors.textMuted)
                      .copyWith(fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          VcTrustBadge(label: member.badge, variant: member.variant),
        ],
      ),
    );
  }
}

// ── Step 5: Orbit ────────────────────────────────────────────────────────────

class OnboardingOrbitIllustration extends StatefulWidget {
  const OnboardingOrbitIllustration({super.key});

  @override
  State<OnboardingOrbitIllustration> createState() =>
      _OnboardingOrbitIllustrationState();
}

class _OnboardingOrbitIllustrationState
    extends State<OnboardingOrbitIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
          ),
          ...[
            (color: AppColors.violet, delay: 0.0, size: 172.0, reverse: false),
            (color: AppColors.mint, delay: 0.33, size: 172.0, reverse: false),
            (color: AppColors.amber, delay: 0.66, size: 172.0, reverse: false),
            (color: AppColors.coral, delay: 0.08, size: 116.0, reverse: true),
            (color: AppColors.violet, delay: 0.48, size: 116.0, reverse: true),
          ].map((orbit) {
            return _OrbitDot(
              controller: _orbit,
              color: orbit.color,
              delay: orbit.delay,
              orbitSize: orbit.size,
              reverse: orbit.reverse,
            );
          }),
          _FloatingLogo(),
          Positioned(
            top: 10,
            right: -16,
            child: VcChip(
              label: '847 verified',
              variant: VcChipVariant.violet,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({
    required this.controller,
    required this.color,
    required this.delay,
    required this.orbitSize,
    required this.reverse,
  });

  final AnimationController controller;
  final Color color;
  final double delay;
  final double orbitSize;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + delay) % 1.0;
        final angle = (reverse ? -1 : 1) * t * 2 * math.pi;
        final radius = orbitSize / 2;
        return Transform.translate(
          offset: Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          ),
          child: child,
        );
      },
      child: Container(
        width: orbitSize > 150 ? 10 : 7,
        height: orbitSize > 150 ? 10 : 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.8),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingLogo extends StatefulWidget {
  @override
  State<_FloatingLogo> createState() => _FloatingLogoState();
}

class _FloatingLogoState extends State<_FloatingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _float.value),
          child: child,
        );
      },
      child: const VcLogoMark(size: 76, violetBorder: true, pulseDot: true),
    );
  }
}
