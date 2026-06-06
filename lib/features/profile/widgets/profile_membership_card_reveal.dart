import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_complete_backdrop.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_membership_card.dart';

/// Layout constants shared by the membership card + reveal animation.
abstract final class ProfileMembershipCardLayout {
  static const aspectRatio = 1.48;
}

/// CRED-style sweep-in + 3D flip reveal for the membership card.
class ProfileMembershipCardReveal extends StatefulWidget {
  const ProfileMembershipCardReveal({
    super.key,
    required this.draft,
    this.memberId,
    this.onRevealComplete,
  });

  final ProfileDraft draft;
  final String? memberId;
  final VoidCallback? onRevealComplete;

  @override
  State<ProfileMembershipCardReveal> createState() =>
      _ProfileMembershipCardRevealState();
}

class _ProfileMembershipCardRevealState extends State<ProfileMembershipCardReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweep;
  late final Animation<double> _flip;
  bool _flipHapticFired = false;
  bool _completeFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );

    _sweep = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic),
    );

    _flip = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 1.0, curve: Curves.easeInOutCubic),
    );

    _controller.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  void _onTick() {
    if (!_flipHapticFired && _flip.value >= 0.48) {
      _flipHapticFired = true;
      HapticFeedback.mediumImpact();
    }
    if (_controller.isCompleted && !_completeFired) {
      _completeFired = true;
      widget.onRevealComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = constraints.maxWidth / ProfileMembershipCardLayout.aspectRatio;

        return SizedBox(
          height: cardHeight,
          width: constraints.maxWidth,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final sweep = _sweep.value;
              final flip = _flip.value;
              final angle = flip * pi;
              final showFront = angle >= pi / 2;

              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: sweep * 0.85,
                    child: const ProfileCompleteBackdrop(),
                  ),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..translate(0.0, (1 - sweep) * 110.0)
                      ..scale(
                        0.76 + 0.24 * sweep,
                        0.76 + 0.24 * sweep,
                        1.0,
                      )
                      ..rotateY(angle),
                    child: showFront
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: VcMembershipCard(
                              draft: widget.draft,
                              memberId: widget.memberId,
                            ),
                          )
                        : const _MembershipCardBack(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MembershipCardBack extends StatelessWidget {
  const _MembershipCardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.violet.withValues(alpha: 0.7),
            const Color(0xFF1A1228),
            AppColors.amber.withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2A1F3D),
                    AppColors.bg,
                    const Color(0xFF0E0C14),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -30,
              child: Icon(
                PhosphorIconsRegular.seal,
                size: 140,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'VETTED CLUB',
                    style: AppTypography.labelCaps(color: AppColors.amber)
                        .copyWith(letterSpacing: 3),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.amber.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.amber.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.crown,
                        size: 32,
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Membership card',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.textSecondary)
                        .copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Flipping your pass…',
                    textAlign: TextAlign.center,
                    style: AppTypography.supporting(color: AppColors.textMuted)
                        .copyWith(fontSize: 11),
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
