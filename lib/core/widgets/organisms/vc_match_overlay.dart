import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/atoms/vc_button.dart';

class VcMatchOverlay extends StatefulWidget {
  const VcMatchOverlay({
    super.key,
    required this.otherName,
    this.yourInitial = 'Y',
    this.otherInitial = 'P',
    this.onSayHi,
    this.visible = true,
  });

  final String otherName;
  final String yourInitial;
  final String otherInitial;
  final VoidCallback? onSayHi;
  final bool visible;

  @override
  State<VcMatchOverlay> createState() => _VcMatchOverlayState();
}

class _VcMatchOverlayState extends State<VcMatchOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.visible) _controller.forward();
  }

  @override
  void didUpdateWidget(VcMatchOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return ColoredBox(
      color: AppColors.bg.withValues(alpha: 0.92),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Staggered(
                controller: _controller,
                index: 0,
                child: Text(
                  "It's mutual.",
                  style: AppTypography.headline(color: AppColors.coral),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _Staggered(
                controller: _controller,
                index: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MatchAvatar(initial: widget.yourInitial),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.favorite,
                        color: AppColors.coral, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    _MatchAvatar(initial: widget.otherInitial),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Staggered(
                controller: _controller,
                index: 2,
                child: Text(
                  'You and ${widget.otherName} both said yes.',
                  style: AppTypography.body(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _Staggered(
                controller: _controller,
                index: 3,
                child: VcButton(
                  label: 'Say hi →',
                  variant: VcButtonVariant.coral,
                  size: VcButtonSize.large,
                  expanded: true,
                  onTap: widget.onSayHi,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  const _MatchAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.s2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.coral, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.coralDark,
            offset: Offset(4, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: AppTypography.headline().copyWith(fontSize: 32),
      ),
    );
  }
}

class _Staggered extends StatelessWidget {
  const _Staggered({
    required this.controller,
    required this.index,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.12;
    final animation = CurvedAnimation(
      parent: controller,
      curve:
          Interval(delay, (delay + 0.6).clamp(0, 1), curve: AppMotion.popCurve),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.82 + (0.18 * animation.value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
