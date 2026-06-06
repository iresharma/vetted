import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_schema_loader.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileFlowResume with real schema', () {
    late ProfileSchema schema;

    setUpAll(() async {
      schema = await ProfileSchemaLoader.load();
    });

    test('complete step 1 API map resumes to interests', () {
      final draft = ProfileDraft.fromMap({
        'displayName': 'Test User',
        'gender': 'man',
        'city': 'Mumbai, Maharashtra',
        'maritalStatus': 'never_married',
        'prompt1A': 'Coffee',
        'prompt2A': 'They laugh',
        'prompt3A': 'Brunch',
        'photoUrls': ['u1', 'u2', 'u3'],
        'trustScore': 25,
      });

      final section = schema.sectionById('you_and_photos')!;
      final form = ProfileFormState(section: section, values: draft.values);
      expect(ProfileValidator.isSectionValid(form), isTrue,
          reason: _missingRequired(form));

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'interests',
      );
    });

    test('snake_case API keys map and resume to interests', () {
      final draft = ProfileDraft.fromMap({
        'display_name': 'Test User',
        'gender': 'woman',
        'city': 'Bangalore, Karnataka',
        'marital_status': 'never_married',
        'prompt_1_a': 'Coffee',
        'prompt_2_a': 'They laugh',
        'prompt_3_a': 'Brunch',
        'photo_urls': ['u1', 'u2', 'u3'],
        'trust_score': 25,
      });

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'interests',
      );
    });

    test('divorced without has_children stays on step 1', () {
      final draft = ProfileDraft.fromMap({
        'displayName': 'Test User',
        'gender': 'woman',
        'city': 'Delhi',
        'maritalStatus': 'divorced',
        'prompt1A': 'Coffee',
        'prompt2A': 'They laugh',
        'prompt3A': 'Brunch',
        'photoUrls': ['u1', 'u2', 'u3'],
      });

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'you_and_photos',
      );
    });
  });
}

String _missingRequired(ProfileFormState form) {
  final missing = <String>[];
  for (final field in form.visibleFields) {
    if (field.status == ProfileFieldStatus.optional) continue;
    if (!ProfileValidator.isFieldFilled(field, form.valueFor(field.id))) {
      missing.add(field.id);
    }
  }
  return 'missing: ${missing.join(', ')}';
}
