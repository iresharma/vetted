import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetted_club_mobile/core/theme/app_colors.dart';

/// Typography scale from design.html section 02.
abstract final class AppTypography {
  static TextStyle get _syne => GoogleFonts.syne();
  static TextStyle get _dmSans => GoogleFonts.dmSans();

  /// DM Sans 700 · large price (₹ aligns on baseline; avoid Syne for currency).
  static TextStyle price({
    Color color = AppColors.textPrimary,
    double fontSize = 40,
  }) =>
      _dmSans.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 1.0,
        letterSpacing: -0.02 * fontSize,
        color: color,
      );

  /// Syne 800 · 48px · display moment
  static TextStyle display({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -0.02 * 48,
        color: color,
      );

  /// Syne 800 · 28px · headline / match moment
  static TextStyle headline({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.01 * 28,
        color: color,
      );

  /// Syne 800 · 20px · profile name / card heading
  static TextStyle title({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: color,
      );

  /// Syne 800 · 18px · screen header count
  static TextStyle headerCount({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: color,
      );

  /// Syne 700 · 11px · section labels / eyebrows
  static TextStyle eyebrow({Color color = AppColors.textMuted}) =>
      _syne.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.14 * 11,
        color: color,
      );

  /// Syne 700 · 10px · uppercase labels in cards
  static TextStyle labelCaps({Color color = AppColors.textMuted}) =>
      _syne.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.1 * 10,
        color: color,
      );

  /// DM Sans 400 · 15px · body / prompt answers
  static TextStyle body({Color color = AppColors.textPrimary}) =>
      _dmSans.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  /// DM Sans 400 · 13px · supporting info
  static TextStyle supporting({Color color = AppColors.textSecondary}) =>
      _dmSans.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  /// DM Sans 600 · 14px · button label
  static TextStyle button({Color color = AppColors.onViolet}) =>
      _dmSans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.01 * 14,
        color: color,
      );

  /// DM Sans 600 · 12px · small button
  static TextStyle buttonSmall({Color color = AppColors.onViolet}) =>
      _dmSans.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  /// Syne 700 · 11px · chip / badge
  static TextStyle chip({Color color = AppColors.violet}) => _syne.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.03 * 11,
        color: color,
      );

  /// Syne 700 · 22px · OTP digit
  static TextStyle otpDigit({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: color,
      );

  /// DM Sans 500 · 11px · uppercase micro labels (splash tagline, stat pills)
  static TextStyle microLabel({Color color = AppColors.textMuted}) =>
      _dmSans.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.16 * 11,
        color: color,
      );

  /// DM Sans 400 · 11px · uppercase stat captions
  static TextStyle statCaption({Color color = AppColors.textMuted}) =>
      _dmSans.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1 * 11,
        color: color,
      );

  /// Syne 700 · 13px · compact titles in onboarding illustrations
  static TextStyle compactTitle({Color color = AppColors.textPrimary}) =>
      _syne.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );
}
