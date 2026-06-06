import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/data/profile_schema_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('birth_place is a city search field in profile.json', () async {
    final schema = await ProfileSchemaLoader.load();
    final field = schema.fieldById('birth_place');

    expect(field, isNotNull);
    expect(field!.type, ProfileFieldType.citySearch);
  });
}
