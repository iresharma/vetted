import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Shared scroll + pull-to-refresh wrapper for main tab pages (profile, trust).
class MemberTabScroll extends StatelessWidget {
  const MemberTabScroll({
    super.key,
    required this.child,
    this.onRefresh,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;

  static const padding = EdgeInsets.fromLTRB(
    AppSpacing.screenHorizontal,
    AppSpacing.md,
    AppSpacing.screenHorizontal,
    AppSpacing.xxxl,
  );

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: padding,
      child: child,
    );

    if (onRefresh == null) return scroll;

    return RefreshIndicator(
      color: AppColors.violet,
      backgroundColor: AppColors.s2,
      onRefresh: onRefresh!,
      child: scroll,
    );
  }
}

/// Section label above grouped content.
class MemberTabSectionLabel extends StatelessWidget {
  const MemberTabSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.eyebrow(color: AppColors.textMuted));
  }
}
