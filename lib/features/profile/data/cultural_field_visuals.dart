import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Icons for faith, family, and lifestyle options in the cultural flow.
abstract final class CulturalFieldVisuals {
  static IconData faithIcon(String option) => switch (option) {
        'Hindu' => PhosphorIconsRegular.flowerLotus,
        'Muslim' => PhosphorIconsRegular.moonStars,
        'Sikh' => PhosphorIconsRegular.star,
        'Christian' => PhosphorIconsRegular.cross,
        'Jain' => PhosphorIconsRegular.leaf,
        'Buddhist' => PhosphorIconsRegular.yinYang,
        'Agnostic' => PhosphorIconsRegular.question,
        'Atheist' => PhosphorIconsRegular.prohibit,
        _ => PhosphorIconsRegular.handsPraying,
      };

  static Color faithColor(String option) => switch (option) {
        'Hindu' => const Color(0xFFE8A945),
        'Muslim' => const Color(0xFF5DADE2),
        'Sikh' => const Color(0xFFE67E22),
        'Christian' => const Color(0xFF3498DB),
        'Jain' => const Color(0xFF1ABC9C),
        'Buddhist' => const Color(0xFF9B59B6),
        _ => const Color(0xFFE8706A),
      };

  static IconData dietIcon(String option) => switch (option) {
        'Vegetarian' => PhosphorIconsRegular.plant,
        'Non-vegetarian' => PhosphorIconsRegular.forkKnife,
        'Eggetarian' => PhosphorIconsRegular.egg,
        'Jain (strict vegetarian)' => PhosphorIconsRegular.leaf,
        'Vegan' => PhosphorIconsRegular.plant,
        _ => PhosphorIconsRegular.forkKnife,
      };

  static IconData familyStructureIcon(String option) => switch (option) {
        'Nuclear' => PhosphorIconsRegular.house,
        'Joint' => PhosphorIconsRegular.houseLine,
        'Open to either' => PhosphorIconsRegular.arrowsMerge,
        _ => PhosphorIconsRegular.users,
      };
}
