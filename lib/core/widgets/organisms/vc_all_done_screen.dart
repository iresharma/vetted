import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_chip.dart';

class VcAllDoneScreen extends StatelessWidget {
  const VcAllDoneScreen({
    super.key,
    required this.countdownLabel,
    this.title = "That's your 5.",
    this.subtitle = 'Come back tomorrow for a fresh batch.',
  });

  final String countdownLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _FloatingIcon(
            child: Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title,
              style: AppTypography.headline(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypography.supporting(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          VcChip(
            label: countdownLabel,
            variant: VcChipVariant.amber,
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  const _FloatingIcon({required this.child});

  final Widget child;

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8 * _controller.value),
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: widget.child,
        ),
      ),
    );
  }
}
