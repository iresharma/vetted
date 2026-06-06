import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_logo_mark.dart';

/// Branded loading state — pulsing logo mark + splash-style shimmer bar.
class VcLoadingIndicator extends StatefulWidget {
  const VcLoadingIndicator({
    super.key,
    this.logoSize = 64,
    this.message,
    this.compact = false,
    this.withGlow = true,
  });

  final double logoSize;
  final String? message;

  /// Hides the shimmer bar for tight overlays (e.g. photo upload).
  final bool compact;

  /// Soft violet radial glow behind the logo.
  final bool withGlow;

  @override
  State<VcLoadingIndicator> createState() => _VcLoadingIndicatorState();
}

class _VcLoadingIndicatorState extends State<VcLoadingIndicator>
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
    final logo = VcLogoMark(
      size: widget.logoSize,
      pulseDot: true,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.withGlow)
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: widget.logoSize * 1.75,
                height: widget.logoSize * 1.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              logo,
            ],
          )
        else
          logo,
        if (!widget.compact) ...[
          SizedBox(height: widget.message != null ? 18 : 16),
          VcLoadingShimmerBar(animation: _shimmer),
        ],
        if (widget.message != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            style: AppTypography.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    return content;
  }
}

/// Sliding violet shimmer used on splash and loading states.
class VcLoadingShimmerBar extends StatelessWidget {
  const VcLoadingShimmerBar({
    super.key,
    required this.animation,
    this.width = 100,
  });

  final Animation<double> animation;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: ColoredBox(
          color: AppColors.s2,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-width + 2 * width * animation.value, 0),
                child: Container(
                  width: width,
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
    );
  }
}
