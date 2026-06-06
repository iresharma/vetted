import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VcEmptyState extends StatelessWidget {
  const VcEmptyState({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.message,
    this.imageHeight = 200,
  });

  final String imageAsset;
  final String title;
  final String message;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            AppSpacing.xxxl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imageAsset,
                  height: imageHeight,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.title().copyWith(fontSize: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bundled illustration paths for empty states.
abstract final class AppAssets {
  static const emptyMailbox = 'assets/images/mailbox_listing.png';
}
