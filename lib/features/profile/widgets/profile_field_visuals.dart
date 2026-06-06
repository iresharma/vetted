import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Icons for profile field labels and option chips.
abstract final class ProfileFieldVisuals {
  static IconData fieldIcon(String fieldId) => switch (fieldId) {
        'display_name' => PhosphorIconsRegular.identificationBadge,
        'gender' => PhosphorIconsRegular.genderIntersex,
        'city' => PhosphorIconsRegular.mapPin,
        'home_state' => PhosphorIconsRegular.house,
        'height_cm' => PhosphorIconsRegular.ruler,
        'body_type' => PhosphorIconsRegular.person,
        'marital_status' => PhosphorIconsRegular.heart,
        'has_children' => PhosphorIconsRegular.baby,
        'grew_up_abroad' => PhosphorIconsRegular.airplaneTilt,
        'photo_urls' => PhosphorIconsRegular.images,
        'interests' => PhosphorIconsRegular.sparkle,
        'education_level' => PhosphorIconsRegular.graduationCap,
        'field_of_work' => PhosphorIconsRegular.briefcase,
        'job_title' => PhosphorIconsRegular.identificationCard,
        'faith' => PhosphorIconsRegular.handsPraying,
        'diet' => PhosphorIconsRegular.forkKnife,
        'marriage_timeline' => PhosphorIconsRegular.calendarHeart,
        _ => PhosphorIconsRegular.circle,
      };

  static IconData optionIcon(String fieldId, String option) {
    if (fieldId == 'gender') {
      return switch (option) {
        'Man' => PhosphorIconsRegular.genderMale,
        'Woman' => PhosphorIconsRegular.genderFemale,
        'Non-binary' => PhosphorIconsRegular.genderNonbinary,
        'Prefer not to say' => PhosphorIconsRegular.eyeSlash,
        _ => PhosphorIconsRegular.user,
      };
    }
    if (fieldId == 'marital_status') {
      return switch (option) {
        'Never married' => PhosphorIconsRegular.smiley,
        'Divorced' => PhosphorIconsRegular.heartBreak,
        'Widowed' => PhosphorIconsRegular.handsClapping,
        'Separated' => PhosphorIconsRegular.arrowsSplit,
        _ => PhosphorIconsRegular.heart,
      };
    }
    if (fieldId == 'body_type') {
      return switch (option) {
        'Slim' => PhosphorIconsRegular.personSimpleRun,
        'Average' => PhosphorIconsRegular.person,
        'Athletic' => PhosphorIconsRegular.barbell,
        'Heavyset' => PhosphorIconsRegular.personArmsSpread,
        'Prefer not to say' => PhosphorIconsRegular.prohibit,
        _ => PhosphorIconsRegular.person,
      };
    }
    return PhosphorIconsRegular.circle;
  }

  static AccentColor sectionAccent(String sectionId) => switch (sectionId) {
        'you_and_photos' => AccentColor.violet,
        'interests' => AccentColor.mint,
        'career' => AccentColor.amber,
        'cultural' => AccentColor.coral,
        _ => AccentColor.violet,
      };

  static List<IconData> sectionHeroIcons(String sectionId) => switch (sectionId) {
        'you_and_photos' => [
            PhosphorIconsRegular.user,
            PhosphorIconsRegular.cameraPlus,
            PhosphorIconsRegular.chatCircle,
          ],
        'interests' => [
            PhosphorIconsRegular.sparkle,
            PhosphorIconsRegular.musicNotes,
            PhosphorIconsRegular.filmSlate,
          ],
        'career' => [
            PhosphorIconsRegular.briefcase,
            PhosphorIconsRegular.graduationCap,
            PhosphorIconsRegular.chartLineUp,
          ],
        'cultural' => [
            PhosphorIconsRegular.handsPraying,
            PhosphorIconsRegular.forkKnife,
            PhosphorIconsRegular.heart,
          ],
        _ => [PhosphorIconsRegular.star],
      };
}
