import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Responsive sizing for the values quiz on small phones.
abstract final class ValuesQuizMetrics {
  static bool compact(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.height < 700 || size.width < 360;
  }

  static double horizontalPadding(BuildContext context) {
    return compact(context) ? AppSpacing.md : AppSpacing.screenHorizontal;
  }

  static double sectionGap(BuildContext context) {
    return compact(context) ? AppSpacing.sm : AppSpacing.lg;
  }
}
