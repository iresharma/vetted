import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_field_mapper.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_schema_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('audit all section options map without drops', () async {
    final schema = await ProfileSchemaLoader.load();
    final failures = <String>[];

    for (final section in schema.sections) {
      final uiValues = _sampleValues(section);
      final dropped = ProfileFieldMapper.droppedFieldIds(
        section: section,
        uiValues: uiValues,
      );
      if (dropped.isNotEmpty) {
        failures.add('${section.id}: $dropped');
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

Map<String, dynamic> _sampleValues(ProfileSection section) {
  final uiValues = <String, dynamic>{};
  for (final field in section.allFields) {
    switch (field.type) {
      case ProfileFieldType.singleSelect:
        if (field.options.isNotEmpty) {
          uiValues[field.id] = field.options.first;
        }
      case ProfileFieldType.multiSelect:
        uiValues[field.id] = field.options.take(3).toList();
      case ProfileFieldType.prompt:
        uiValues[field.id] = 'Sample answer';
      case ProfileFieldType.photoUpload:
        uiValues[field.id] = ['https://a', 'https://b', 'https://c'];
      case ProfileFieldType.number:
        uiValues[field.id] = '170';
      case ProfileFieldType.time:
        uiValues[field.id] = '14:30';
      case ProfileFieldType.text:
      case ProfileFieldType.citySearch:
        uiValues[field.id] = 'Sample';
    }
  }
  return uiValues;
}
