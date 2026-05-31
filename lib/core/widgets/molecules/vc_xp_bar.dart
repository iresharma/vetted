import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VcXpBar extends StatefulWidget {
  const VcXpBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.animateOnMount = true,
    this.label,
    this.showPercentage = false,
  });

  final double progress;
  final double height;
  final bool animateOnMount;
  final String? label;
  final bool showPercentage;

  @override
  State<VcXpBar> createState() => _VcXpBarState();
}

class _VcXpBarState extends State<VcXpBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.xpFillDuration,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress.clamp(0, 1))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    ));

    if (widget.animateOnMount) {
      Future<void>.delayed(AppMotion.xpFillDelay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(VcXpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress.clamp(0, 1),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppMotion.standardCurve,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bar = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.s3),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.violet, AppColors.amber],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (widget.label == null && !widget.showPercentage) return bar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label != null)
              Text(widget.label!, style: AppTypography.labelCaps()),
            if (widget.showPercentage)
              Text(
                '${(widget.progress * 100).round()}%',
                style: AppTypography.chip(color: AppColors.amber),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        bar,
      ],
    );
  }
}
