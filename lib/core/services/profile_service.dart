import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:vetted_club_mobile/core/services/functions_service.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';

export 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart'
    show ProfileDraft;

class ProfileSaveResult {
  const ProfileSaveResult({
    required this.trustScore,
    required this.trustTier,
    required this.profilePoints,
    required this.behaviorPoints,
    required this.isLive,
    this.photoUrls = const [],
  });

  final int trustScore;
  final String trustTier;
  final int profilePoints;
  final int behaviorPoints;
  final bool isLive;
  final List<String> photoUrls;
}

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  Future<ProfileDraft> loadDraft() async {
    final response = await FunctionsService.instance.call('getProfileDraft');
    return ProfileDraft.fromMap(response);
  }

  Future<ProfileSaveResult> saveFields(Map<String, dynamic> payload) async {
    try {
      final response = await FunctionsService.instance.call(
        'saveProfileStep',
        data: payload,
      );
      final saved = response['photoUrls'];
      return ProfileSaveResult(
        trustScore: (response['trustScore'] as num?)?.toInt() ?? 0,
        trustTier: (response['trustTier'] as String?) ?? 'trusted',
        profilePoints: (response['profilePoints'] as num?)?.toInt() ?? 0,
        behaviorPoints: (response['behaviorPoints'] as num?)?.toInt() ?? 0,
        isLive: response['isLive'] == true,
        photoUrls: saved is List
            ? saved.whereType<String>().where((u) => u.isNotEmpty).toList()
            : const [],
      );
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) {
        debugPrint('saveProfileStep failed: ${e.code} ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<String>> savePhotoUrls(List<String> photoUrls) async {
    final result = await saveFields({'photo_urls': photoUrls});
    return result.photoUrls.isNotEmpty ? result.photoUrls : photoUrls;
  }
}
