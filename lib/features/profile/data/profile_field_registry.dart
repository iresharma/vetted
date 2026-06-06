import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';

/// Maps UI field ids to DB keys and storage targets.
class ProfileFieldRegistry {
  const ProfileFieldRegistry._();

  static const extrasFieldIds = {
    'weekend_vibe',
    'sleep_schedule',
    'travel_frequency',
    'exercise_frequency',
    'pet_preference',
    'social_media_presence',
    'mbti',
    'love_language',
    'partner_search_approach',
    'spouse_working_preference',
    'disability',
  };

  static ProfileFieldStorage storageFor(String fieldId) {
    if (extrasFieldIds.contains(fieldId)) {
      return ProfileFieldStorage.extras;
    }
    return ProfileFieldStorage.column;
  }

  static String dbKeyFor(String fieldId) => switch (fieldId) {
        'job_title' => 'profession',
        'wants_children' => 'kids_preference',
        'prompt_1' => 'prompt_1_a',
        'prompt_2' => 'prompt_2_a',
        'prompt_3' => 'prompt_3_a',
        'photo_urls' => 'photo_urls',
        _ => fieldId,
      };

  static String? promptQuestionKey(String fieldId) => switch (fieldId) {
        'prompt_1' => 'prompt_1_q',
        'prompt_2' => 'prompt_2_q',
        'prompt_3' => 'prompt_3_q',
        _ => null,
      };

  static void enrichSchema(ProfileSchema schema) {
    // Enrichment happens at parse time via registry lookups in mapper.
  }
}
