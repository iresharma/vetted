import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';

class ProfileProgress {
  const ProfileProgress._();

  static double sectionProgress(ProfileFormState state) =>
      ProfileValidator.sectionProgress(state);

  static double overallFromSections(
    ProfileSchema schema,
    Map<String, ProfileFormState> sectionStates,
  ) {
    if (schema.sections.isEmpty) return 0;
    var totalWeight = 0;
    var weighted = 0.0;
    for (final section in schema.sections) {
      final state = sectionStates[section.id];
      if (state == null) continue;
      totalWeight += section.xpWeight;
      weighted += sectionProgress(state) * section.xpWeight;
    }
    if (totalWeight == 0) return 0;
    return weighted / totalWeight;
  }
}
