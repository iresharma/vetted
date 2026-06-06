import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Staggered fade + slide for the profile completion headline.
class ProfileCompleteHero extends StatefulWidget {
  const ProfileCompleteHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.startWhen = true,
  });

  final String title;
  final String subtitle;
  final bool startWhen;

  @override
  State<ProfileCompleteHero> createState() => _ProfileCompleteHeroState();
}

class _ProfileCompleteHeroState extends State<ProfileCompleteHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.75, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.75, curve: Curves.easeOutCubic),
    ));

    if (widget.startWhen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ProfileCompleteHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startWhen && !oldWidget.startWhen && !_controller.isAnimating) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeTransition(
          opacity: _titleFade,
          child: SlideTransition(
            position: _titleSlide,
            child: Text(
              widget.title,
              style: AppTypography.display().copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: _subtitleFade,
          child: SlideTransition(
            position: _subtitleSlide,
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(color: AppColors.textSecondary)
                  .copyWith(fontSize: 15, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
