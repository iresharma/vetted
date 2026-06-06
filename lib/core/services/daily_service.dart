import 'package:vetted_club_mobile/core/services/functions_service.dart';

class DailyService {
  DailyService._();

  static final DailyService instance = DailyService._();

  Future<DailyQueueResponse> getDailyQueue() async {
    final data = await FunctionsService.instance.call('getDailyQueue');
    return DailyQueueResponse.fromMap(data);
  }

  Future<void> markShown(String queueId) async {
    await FunctionsService.instance.call(
      'markDailyQueueShown',
      data: {'queueId': queueId},
    );
  }

  Future<DailyInteractionResult> recordInteraction({
    required String targetUid,
    required String type,
    String? passReason,
    String? passReasonField,
  }) async {
    final data = await FunctionsService.instance.call(
      'recordDailyInteraction',
      data: {
        'targetUid': targetUid,
        'type': type,
        if (passReason != null) 'passReason': passReason,
        if (passReasonField != null) 'passReasonField': passReasonField,
      },
    );
    return DailyInteractionResult.fromMap(data);
  }
}

class DailyInteractionResult {
  const DailyInteractionResult({required this.isMutual});

  final bool isMutual;

  factory DailyInteractionResult.fromMap(Map<String, dynamic> map) {
    return DailyInteractionResult(isMutual: map['isMutual'] == true);
  }
}

class DailyQueueResponse {
  const DailyQueueResponse({
    required this.entries,
    required this.queueDate,
  });

  final List<DailyQueueEntry> entries;
  final String queueDate;

  factory DailyQueueResponse.fromMap(Map<String, dynamic> map) {
    final raw = map['entries'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => DailyQueueEntry.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <DailyQueueEntry>[];
    return DailyQueueResponse(
      entries: list,
      queueDate: (map['queueDate'] as String?) ?? '',
    );
  }
}

class DailyQueueEntry {
  const DailyQueueEntry({
    required this.id,
    required this.position,
    required this.compatibilityScore,
    required this.matchReasonField,
    required this.matchReasonLabel,
    required this.wasShown,
    required this.profile,
    this.scoreBreakdown = const {},
  });

  final String id;
  final int position;
  final int compatibilityScore;
  final String? matchReasonField;
  final String? matchReasonLabel;
  final bool wasShown;
  final DailyProfileSummary profile;
  final Map<String, dynamic> scoreBreakdown;

  factory DailyQueueEntry.fromMap(Map<String, dynamic> map) {
    final profileRaw = map['profile'];
    return DailyQueueEntry(
      id: (map['id'] as String?) ?? '',
      position: (map['position'] as num?)?.toInt() ?? 0,
      compatibilityScore: (map['compatibilityScore'] as num?)?.toInt() ?? 0,
      matchReasonField: map['matchReasonField'] as String?,
      matchReasonLabel: map['matchReasonLabel'] as String?,
      wasShown: map['wasShown'] == true,
      scoreBreakdown: map['scoreBreakdown'] is Map
          ? Map<String, dynamic>.from(map['scoreBreakdown'] as Map)
          : const {},
      profile: profileRaw is Map
          ? DailyProfileSummary.fromMap(Map<String, dynamic>.from(profileRaw))
          : const DailyProfileSummary(uid: ''),
    );
  }
}

class DailyProfileSummary {
  const DailyProfileSummary({
    required this.uid,
    this.displayName,
    this.age,
    this.city,
    this.profession,
    this.faith,
    this.motherTongue,
    this.marriageTimeline,
    this.photoUrls = const [],
    this.trustScore = 0,
    this.trustTier = 'trusted',
    this.prompt1Q,
    this.prompt1A,
    this.prompt2Q,
    this.prompt2A,
    this.prompt3Q,
    this.prompt3A,
    this.interests = const [],
  });

  final String uid;
  final String? displayName;
  final int? age;
  final String? city;
  final String? profession;
  final String? faith;
  final String? motherTongue;
  final String? marriageTimeline;
  final List<String> photoUrls;
  final int trustScore;
  final String trustTier;
  final String? prompt1Q;
  final String? prompt1A;
  final String? prompt2Q;
  final String? prompt2A;
  final String? prompt3Q;
  final String? prompt3A;
  final List<String> interests;

  String? get primaryPhoto =>
      photoUrls.isNotEmpty ? photoUrls.first : null;

  List<({String question, String answer})> get prompts {
    final items = <({String question, String answer})>[];
    void add(String? q, String? a) {
      if (q != null && q.isNotEmpty && a != null && a.isNotEmpty) {
        items.add((question: q, answer: a));
      }
    }

    add(prompt1Q, prompt1A);
    add(prompt2Q, prompt2A);
    add(prompt3Q, prompt3A);
    return items;
  }

  factory DailyProfileSummary.fromMap(Map<String, dynamic> map) {
    List<String> asStringList(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) => e.toString()).toList();
    }

    return DailyProfileSummary(
      uid: (map['uid'] as String?) ?? '',
      displayName: map['displayName'] as String?,
      age: (map['age'] as num?)?.toInt(),
      city: map['city'] as String?,
      profession: map['profession'] as String?,
      faith: map['faith'] as String?,
      motherTongue: map['motherTongue'] as String?,
      marriageTimeline: map['marriageTimeline'] as String?,
      photoUrls: asStringList(map['photoUrls']),
      trustScore: (map['trustScore'] as num?)?.toInt() ?? 0,
      trustTier: (map['trustTier'] as String?) ?? 'trusted',
      prompt1Q: map['prompt1Q'] as String?,
      prompt1A: map['prompt1A'] as String?,
      prompt2Q: map['prompt2Q'] as String?,
      prompt2A: map['prompt2A'] as String?,
      prompt3Q: map['prompt3Q'] as String?,
      prompt3A: map['prompt3A'] as String?,
      interests: asStringList(map['interests']),
    );
  }
}
