import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Icons for education and industry options in the career flow.
abstract final class CareerFieldVisuals {
  static IconData educationIcon(String option) => switch (option) {
        'High school' => PhosphorIconsRegular.student,
        'Diploma' => PhosphorIconsRegular.certificate,
        "Bachelor's" => PhosphorIconsRegular.graduationCap,
        "Master's" => PhosphorIconsRegular.bookOpenText,
        'MBA' => PhosphorIconsRegular.chartLineUp,
        'PhD / Doctorate' => PhosphorIconsRegular.atom,
        'MBBS / MD' => PhosphorIconsRegular.firstAid,
        'CA / CFA / CS' => PhosphorIconsRegular.calculator,
        'Still studying' => PhosphorIconsRegular.bookBookmark,
        _ => PhosphorIconsRegular.graduationCap,
      };

  static IconData industryIcon(String option) => switch (option) {
        'Software & technology' => PhosphorIconsRegular.code,
        'Engineering' => PhosphorIconsRegular.wrench,
        'Finance & banking' => PhosphorIconsRegular.bank,
        'Medicine & healthcare' => PhosphorIconsRegular.stethoscope,
        'Law' => PhosphorIconsRegular.scales,
        'Design & creative' => PhosphorIconsRegular.paintBrush,
        'Marketing & media' => PhosphorIconsRegular.megaphone,
        'Consulting & strategy' => PhosphorIconsRegular.lightbulb,
        'Research & academia' => PhosphorIconsRegular.flask,
        'Government & public sector' => PhosphorIconsRegular.buildings,
        'Entrepreneurship / startup' => PhosphorIconsRegular.rocketLaunch,
        'Manufacturing & engineering' => PhosphorIconsRegular.gear,
        'Architecture' => PhosphorIconsRegular.compassTool,
        'Social sector / NGO' => PhosphorIconsRegular.handHeart,
        'Arts & entertainment' => PhosphorIconsRegular.filmSlate,
        _ => PhosphorIconsRegular.briefcase,
      };

  static Color industryColor(String option) => switch (option) {
        'Software & technology' => const Color(0xFF7C6AF5),
        'Engineering' => const Color(0xFF5DADE2),
        'Finance & banking' => const Color(0xFF3498DB),
        'Medicine & healthcare' => const Color(0xFFE8706A),
        'Law' => const Color(0xFF9B59B6),
        'Design & creative' => const Color(0xFFE8A945),
        'Marketing & media' => const Color(0xFF1ABC9C),
        'Entrepreneurship / startup' => const Color(0xFFE67E22),
        _ => const Color(0xFF6B6A78),
      };
}
