import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';

class ProfileSchemaLoader {
  const ProfileSchemaLoader._();

  static Future<ProfileSchema> load() async {
    final raw = await rootBundle.loadString('profile.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ProfileSchema.fromJson(json);
  }
}
