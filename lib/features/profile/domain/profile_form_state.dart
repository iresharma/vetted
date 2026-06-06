import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';

class ProfileFormState {
  ProfileFormState({
    required this.section,
    Map<String, dynamic>? values,
  }) : values = Map<String, dynamic>.from(values ?? {});

  final ProfileSection section;
  final Map<String, dynamic> values;

  void setValue(String fieldId, dynamic value) {
    values[fieldId] = value;
  }

  dynamic valueFor(String fieldId) => values[fieldId];

  bool isVisible(ProfileField field) {
    final rule = field.showIf;
    if (rule == null) return true;

    final current = values[rule.field];
    if (current == null) return false;

    if (rule.notEquals != null) {
      return current.toString() != rule.notEquals;
    }
    if (rule.equals != null) {
      return current.toString() == rule.equals;
    }
    return true;
  }

  List<ProfileField> get visibleFields =>
      section.allFields.where(isVisible).toList();

  ProfileFormState copyWithValues(Map<String, dynamic> newValues) {
    return ProfileFormState(
      section: section,
      values: {...values, ...newValues},
    );
  }
}
