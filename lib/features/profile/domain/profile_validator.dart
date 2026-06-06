import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';

class ProfileValidator {
  const ProfileValidator._();

  static bool isFieldFilled(ProfileField field, dynamic value) {
    if (value == null) return false;
    if (field.type == ProfileFieldType.photoUpload) {
      if (value is! List) return false;
      final min = field.minCount ?? 1;
      return value.isNotEmpty && value.length >= min;
    }
    if (field.type == ProfileFieldType.multiSelect) {
      if (value is! List || value.isEmpty) return false;
      final min = field.minCount;
      if (min != null && value.length < min) return false;
      return true;
    }
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  static bool isSectionValid(ProfileFormState state) {
    for (final field in state.visibleFields) {
      if (field.status == ProfileFieldStatus.optional) continue;
      if (!isFieldFilled(field, state.valueFor(field.id))) {
        return false;
      }
    }
    return true;
  }

  static int requiredRemaining(ProfileFormState state) {
    var count = 0;
    for (final field in state.visibleFields) {
      if (field.status == ProfileFieldStatus.optional) continue;
      if (!isFieldFilled(field, state.valueFor(field.id))) {
        count++;
      }
    }
    return count;
  }

  static double sectionProgress(ProfileFormState state) {
    final requiredFields = state.visibleFields
        .where((f) => f.status != ProfileFieldStatus.optional)
        .toList();
    if (requiredFields.isEmpty) return 1;

    var done = 0;
    for (final field in requiredFields) {
      if (isFieldFilled(field, state.valueFor(field.id))) done++;
    }
    return done / requiredFields.length;
  }
}
