import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_field_mapper.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_schema_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileFieldMapper', () {
    late ProfileSchema schema;

    setUpAll(() async {
      schema = await ProfileSchemaLoader.load();
    });

    test('maps weekend_vibe into profile_extras', () {
      final section = schema.sectionById('interests')!;
      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: {
          'interests': ['Reading', 'Music', 'Travel'],
          'weekend_vibe': ['Social — out with friends'],
        },
      );

      expect(payload['interests'], isA<List>());
      expect(payload['profile_extras'], isA<Map>());
      expect(
        (payload['profile_extras'] as Map)['weekend_vibe'],
        ['Social — out with friends'],
      );
    });

    test('maps partner_search_approach into profile_extras', () {
      final section = schema.sectionById('cultural')!;
      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: {
          'partner_search_approach':
              'Date first — get to know each other before deciding',
        },
      );

      expect(
        (payload['profile_extras'] as Map)['partner_search_approach'],
        'Date first — get to know each other before deciding',
      );
    });

    test('maps willing_to_relocate possibly as false with extras label', () {
      final section = schema.sectionById('cultural')!;
      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: {
          'willing_to_relocate': 'Possibly — depends on where',
        },
      );

      expect(payload['willing_to_relocate'], isFalse);
      expect(
        (payload['profile_extras'] as Map)['willing_to_relocate_label'],
        'Possibly — depends on where',
      );
    });

    test('accepts db enum values on reload save cycle', () {
      final section = schema.sectionById('you_and_photos')!;
      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: {
          'marital_status': 'never_married',
          'gender': 'man',
        },
      );

      expect(payload['marital_status'], 'never_married');
      expect(payload['gender'], 'man');
      expect(
        ProfileFieldMapper.droppedFieldIds(
          section: section,
          uiValues: {
            'marital_status': 'never_married',
            'gender': 'man',
          },
        ),
        isEmpty,
      );
    });

    test('maps field_of_work label to column', () {
      final section = schema.sectionById('career')!;
      final payload = ProfileFieldMapper.toApiPayload(
        section: section,
        uiValues: {
          'field_of_work': 'Software & technology',
          'job_title': 'Software Engineer',
        },
      );

      expect(payload['field_of_work'], 'Software & technology');
      expect(payload['profession'], 'Software Engineer');
    });
  });
}
