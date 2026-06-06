import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';

void main() {
  group('ProfileFlowResume', () {
    test('returns null for empty draft', () {
      const schema = ProfileSchema(version: 1, requiredForLive: [], sections: []);
      expect(
        ProfileFlowResume.resumeTarget(draft: null, schema: schema),
        isNull,
      );
    });

    test('returns first incomplete section when only one has progress', () {
      final schema = ProfileSchema(
        version: 1,
        requiredForLive: [],
        sections: [
          ProfileSection(
            id: 'you_and_photos',
            step: 1,
            title: 'You',
            subtitle: '',
            xpWeight: 30,
            fields: [
              ProfileField(
                id: 'display_name',
                label: 'Name',
                type: ProfileFieldType.text,
                status: ProfileFieldStatus.required,
              ),
            ],
          ),
          ProfileSection(
            id: 'interests',
            step: 2,
            title: 'Interests',
            subtitle: '',
            xpWeight: 15,
            fields: [
              ProfileField(
                id: 'interests',
                label: 'Interests',
                type: ProfileFieldType.multiSelect,
                status: ProfileFieldStatus.required,
                minCount: 3,
                options: ['Reading', 'Music', 'Travel'],
              ),
            ],
          ),
        ],
      );

      final draft = ProfileDraft(
        values: {'display_name': 'Iresh'},
      );

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'interests',
      );
    });

    test('resumes at career when interests gap but career has progress', () {
      final schema = ProfileSchema(
        version: 1,
        requiredForLive: [],
        sections: [
          ProfileSection(
            id: 'you_and_photos',
            step: 1,
            title: 'You',
            subtitle: '',
            xpWeight: 30,
            fields: [
              ProfileField(
                id: 'display_name',
                label: 'Name',
                type: ProfileFieldType.text,
                status: ProfileFieldStatus.required,
              ),
            ],
          ),
          ProfileSection(
            id: 'interests',
            step: 2,
            title: 'Interests',
            subtitle: '',
            xpWeight: 15,
            fields: [
              ProfileField(
                id: 'interests',
                label: 'Interests',
                type: ProfileFieldType.multiSelect,
                status: ProfileFieldStatus.required,
                minCount: 3,
                options: ['Reading', 'Music', 'Travel'],
              ),
              ProfileField(
                id: 'weekend_vibe',
                label: 'Weekend',
                type: ProfileFieldType.multiSelect,
                status: ProfileFieldStatus.required,
                minCount: 1,
                options: ['Social — out with friends'],
              ),
            ],
          ),
          ProfileSection(
            id: 'career',
            step: 3,
            title: 'Career',
            subtitle: '',
            xpWeight: 25,
            fields: [
              ProfileField(
                id: 'education_level',
                label: 'Education',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ["Bachelor's"],
              ),
              ProfileField(
                id: 'field_of_work',
                label: 'Field',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ['Engineering'],
              ),
              ProfileField(
                id: 'job_title',
                label: 'Role',
                type: ProfileFieldType.text,
                status: ProfileFieldStatus.required,
              ),
            ],
          ),
        ],
      );

      final draft = ProfileDraft(
        values: {
          'display_name': 'Iresh',
          'interests': ['Reading', 'Music', 'Travel'],
          'weekend_vibe': ['Social — out with friends'],
          'education_level': "Bachelor's",
          'job_title': 'Engineer',
        },
      );

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'career',
      );
    });

    test('skips interests gap when career is already complete', () {
      final schema = ProfileSchema(
        version: 1,
        requiredForLive: [],
        sections: [
          ProfileSection(
            id: 'you_and_photos',
            step: 1,
            title: 'You',
            subtitle: '',
            xpWeight: 30,
            fields: [
              ProfileField(
                id: 'display_name',
                label: 'Name',
                type: ProfileFieldType.text,
                status: ProfileFieldStatus.required,
              ),
            ],
          ),
          ProfileSection(
            id: 'interests',
            step: 2,
            title: 'Interests',
            subtitle: '',
            xpWeight: 15,
            fields: [
              ProfileField(
                id: 'interests',
                label: 'Interests',
                type: ProfileFieldType.multiSelect,
                status: ProfileFieldStatus.required,
                minCount: 3,
                options: ['Reading', 'Music', 'Travel'],
              ),
              ProfileField(
                id: 'weekend_vibe',
                label: 'Weekend',
                type: ProfileFieldType.multiSelect,
                status: ProfileFieldStatus.required,
                minCount: 1,
                options: ['Social — out with friends'],
              ),
            ],
          ),
          ProfileSection(
            id: 'career',
            step: 3,
            title: 'Career',
            subtitle: '',
            xpWeight: 25,
            fields: [
              ProfileField(
                id: 'education_level',
                label: 'Education',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ["Bachelor's"],
              ),
              ProfileField(
                id: 'field_of_work',
                label: 'Field',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ['Software & technology'],
              ),
              ProfileField(
                id: 'job_title',
                label: 'Role',
                type: ProfileFieldType.text,
                status: ProfileFieldStatus.required,
              ),
            ],
          ),
          ProfileSection(
            id: 'cultural',
            step: 4,
            title: 'Cultural',
            subtitle: '',
            xpWeight: 25,
            fields: [
              ProfileField(
                id: 'faith',
                label: 'Faith',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ['Hindu'],
              ),
              ProfileField(
                id: 'mother_tongue',
                label: 'Tongue',
                type: ProfileFieldType.singleSelect,
                status: ProfileFieldStatus.required,
                options: ['Hindi'],
              ),
            ],
          ),
        ],
      );

      final draft = ProfileDraft(
        values: {
          'display_name': 'Iresh',
          'interests': ['Reading', 'Music', 'Travel'],
          'education_level': "Bachelor's",
          'field_of_work': 'Software & technology',
          'job_title': 'Software Engineer',
          'faith': 'Hindu',
        },
      );

      expect(
        ProfileFlowResume.resumeTarget(draft: draft, schema: schema),
        'cultural',
      );
    });
  });

  group('ProfileInterestsMicroResume', () {
    test('restores micro step from saved values', () {
      expect(
        ProfileInterestsMicroResume.microStepIndex(values: {}),
        0,
      );
      expect(
        ProfileInterestsMicroResume.microStepIndex(
          values: {
            'interests': ['Reading', 'Music', 'Travel'],
          },
        ),
        1,
      );
      expect(
        ProfileInterestsMicroResume.microStepIndex(
          values: {
            'interests': ['Reading', 'Music', 'Travel'],
            'weekend_vibe': ['Social — out with friends'],
          },
        ),
        2,
      );
    });
  });

  group('ProfileCareerMicroResume', () {
    test('restores micro step from saved values', () {
      expect(ProfileCareerMicroResume.microStepIndex(values: {}), 0);
      expect(
        ProfileCareerMicroResume.microStepIndex(
          values: {'education_level': "Bachelor's"},
        ),
        1,
      );
      expect(
        ProfileCareerMicroResume.microStepIndex(
          values: {
            'education_level': "Bachelor's",
            'field_of_work': 'Software & technology',
            'job_title': 'Engineer',
          },
        ),
        2,
      );
    });
  });

  group('ProfileCulturalMicroResume', () {
    test('restores micro step from saved values', () {
      expect(ProfileCulturalMicroResume.microStepIndex(values: {}), 0);
      expect(
        ProfileCulturalMicroResume.microStepIndex(
          values: {'faith': 'Hindu', 'mother_tongue': 'Hindi'},
        ),
        1,
      );
      expect(
        ProfileCulturalMicroResume.microStepIndex(
          values: {
            'faith': 'Hindu',
            'mother_tongue': 'Hindi',
            'family_structure': 'Nuclear',
            'family_involvement': 'This is private for now',
          },
        ),
        2,
      );
      expect(
        ProfileCulturalMicroResume.microStepIndex(
          values: {
            'faith': 'Hindu',
            'mother_tongue': 'Hindi',
            'family_structure': 'Nuclear',
            'family_involvement': 'This is private for now',
            'diet': 'Vegetarian',
            'drinking': 'Never',
            'smoking': 'Never',
          },
        ),
        3,
      );
    });
  });
}
