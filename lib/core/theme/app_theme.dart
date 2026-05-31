import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/theme/app_colors.dart';
import 'package:vetted_club_mobile/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.bg,
        onSurface: AppColors.textPrimary,
        primary: AppColors.violet,
        onPrimary: AppColors.onViolet,
        secondary: AppColors.amber,
        error: AppColors.coral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.title(),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.s1,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      dividerColor: AppColors.border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: TextTheme(
        displayLarge: AppTypography.display(),
        headlineMedium: AppTypography.headline(),
        titleLarge: AppTypography.title(),
        bodyLarge: AppTypography.body(),
        bodyMedium: AppTypography.supporting(),
        labelSmall: AppTypography.eyebrow(),
      ),
    );
  }
}
