import 'package:vetted_club_mobile/core/services/functions_service.dart';

class ProfileDraft {
  const ProfileDraft({
    required this.verifiedName,
    required this.verifiedAge,
    required this.photoUrls,
  });

  final String? verifiedName;
  final int? verifiedAge;
  final List<String> photoUrls;

  factory ProfileDraft.fromMap(Map<String, dynamic> map) {
    final rawPhotos = map['photoUrls'];
    return ProfileDraft(
      verifiedName: map['verifiedName'] as String?,
      verifiedAge: (map['verifiedAge'] as num?)?.toInt(),
      photoUrls: rawPhotos is List
          ? rawPhotos.whereType<String>().where((url) => url.isNotEmpty).toList()
          : const [],
    );
  }
}

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  Future<ProfileDraft> loadDraft() async {
    final response = await FunctionsService.instance.call('getProfileDraft');
    return ProfileDraft.fromMap(response);
  }

  Future<void> savePhotoUrls(List<String> photoUrls) async {
    await FunctionsService.instance.call(
      'saveProfileStep',
      data: {'photo_urls': photoUrls},
    );
  }
}
