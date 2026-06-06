import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';

void main() {
  group('ProfileValidator', () {
    test('has_children hidden when never married', () {
      const section = ProfileSection(
        id: 'you_and_photos',
        step: 1,
        title: 'Test',
        subtitle: 'Test',
        xpWeight: 30,
        fields: [
          ProfileField(
            id: 'marital_status',
            label: 'Marital status',
            type: ProfileFieldType.singleSelect,
            status: ProfileFieldStatus.required,
            options: ['Never married', 'Divorced'],
          ),
          ProfileField(
            id: 'has_children',
            label: 'Children',
            type: ProfileFieldType.singleSelect,
            status: ProfileFieldStatus.conditional,
            options: ['No', 'Yes — 1 child'],
            showIf: ShowIfRule(field: 'marital_status', notEquals: 'Never married'),
          ),
        ],
      );

      final state = ProfileFormState(
        section: section,
        values: {'marital_status': 'Never married'},
      );

      expect(state.visibleFields.map((f) => f.id), ['marital_status']);
      expect(ProfileValidator.isSectionValid(state), isTrue);
    });

    test('photo field requires min count', () {
      const field = ProfileField(
        id: 'photo_urls',
        label: 'Photos',
        type: ProfileFieldType.photoUpload,
        status: ProfileFieldStatus.required,
        minCount: 3,
        maxCount: 8,
      );

      expect(ProfileValidator.isFieldFilled(field, ['a', 'b']), isFalse);
      expect(ProfileValidator.isFieldFilled(field, ['a', 'b', 'c']), isTrue);
    });
  });
}
