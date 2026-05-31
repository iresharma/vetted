import 'package:flutter/material.dart';

/// Design tokens from design.html — single source of truth for colour.
abstract final class AppColors {
  // Surfaces
  static const bg = Color(0xFF0A0A0F);
  static const s1 = Color(0xFF111118);
  static const s2 = Color(0xFF17171E);
  static const s3 = Color(0xFF1E1E28);
  static const s4 = Color(0xFF252530);
  static const border = Color(0xFF272736);

  // Accents
  static const violet = Color(0xFF7C6AF5);
  static const violetDark = Color(0xFF4A3DB8);
  static const violetDim = Color(0x1F7C6AF5); // rgba(124,106,245,0.12)

  static const amber = Color(0xFFE8A945);
  static const amberDark = Color(0xFF9A6A10);
  static const amberDim = Color(0x1FE8A945);

  static const coral = Color(0xFFE8706A);
  static const coralDark = Color(0xFF9A3030);
  static const coralDim = Color(0x1FE8706A);

  static const mint = Color(0xFF4AE0A0);
  static const mintDark = Color(0xFF1A8A50);
  static const mintDim = Color(0x1A4AE0A0);

  // Text
  static const textPrimary = Color(0xFFF0EFF5);
  static const textSecondary = Color(0xFF6B6A78);
  static const textMuted = Color(0xFF3D3C49);

  // Semantic shortcuts
  static const onViolet = Color(0xFFFFFFFF);
  static const onAmber = Color(0xFF1A0A00);
}

enum AccentColor {
  violet(AppColors.violet, AppColors.violetDark, AppColors.violetDim),
  amber(AppColors.amber, AppColors.amberDark, AppColors.amberDim),
  coral(AppColors.coral, AppColors.coralDark, AppColors.coralDim),
  mint(AppColors.mint, AppColors.mintDark, AppColors.mintDim);

  const AccentColor(this.main, this.dark, this.dim);

  final Color main;
  final Color dark;
  final Color dim;
}
