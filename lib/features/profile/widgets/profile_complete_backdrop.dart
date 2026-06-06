import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Ambient glow behind the membership card on profile completion.
class ProfileCompleteBackdrop extends StatelessWidget {
  const ProfileCompleteBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: const [
          Positioned(
            top: -20,
            left: -48,
            child: _GlowOrb(
              color: AppColors.violet,
              size: 220,
              opacity: 0.2,
            ),
          ),
          Positioned(
            top: 40,
            right: -56,
            child: _GlowOrb(
              color: AppColors.amber,
              size: 180,
              opacity: 0.16,
            ),
          ),
          Positioned(
            bottom: -10,
            left: 24,
            child: _GlowOrb(
              color: AppColors.mint,
              size: 140,
              opacity: 0.1,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment(0, 0.2),
              child: _GlowOrb(
                color: AppColors.violet,
                size: 280,
                opacity: 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}
