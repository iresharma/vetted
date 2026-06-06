import 'package:vetted_club_mobile/features/trust/data/models/trust_breakdown.dart';

class TrustScoreEvent {
  const TrustScoreEvent({
    required this.id,
    required this.createdAt,
    required this.eventType,
    required this.category,
    required this.title,
    this.body,
    required this.deltaProfile,
    required this.deltaBehavior,
    required this.deltaTotal,
    this.profilePointsAfter,
    this.behaviorPointsAfter,
    required this.scoreBefore,
    required this.scoreAfter,
    this.tierAfter,
    this.metadata = const {},
  });

  final String id;
  final DateTime createdAt;
  final String eventType;
  final String category;
  final String title;
  final String? body;
  final int deltaProfile;
  final int deltaBehavior;
  final int deltaTotal;
  final int? profilePointsAfter;
  final int? behaviorPointsAfter;
  final int scoreBefore;
  final int scoreAfter;
  final String? tierAfter;
  final Map<String, dynamic> metadata;

  factory TrustScoreEvent.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return TrustScoreEvent(
      id: map['id']?.toString() ?? '',
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      eventType: map['eventType']?.toString() ?? map['event_type']?.toString() ?? '',
      category: map['category']?.toString() ?? 'system',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString(),
      deltaProfile: (map['deltaProfile'] as num?)?.toInt() ??
          (map['delta_profile'] as num?)?.toInt() ??
          0,
      deltaBehavior: (map['deltaBehavior'] as num?)?.toInt() ??
          (map['delta_behavior'] as num?)?.toInt() ??
          0,
      deltaTotal: (map['deltaTotal'] as num?)?.toInt() ??
          (map['delta_total'] as num?)?.toInt() ??
          0,
      profilePointsAfter: (map['profilePointsAfter'] as num?)?.toInt() ??
          (map['profile_points_after'] as num?)?.toInt(),
      behaviorPointsAfter: (map['behaviorPointsAfter'] as num?)?.toInt() ??
          (map['behavior_points_after'] as num?)?.toInt(),
      scoreBefore: (map['scoreBefore'] as num?)?.toInt() ??
          (map['score_before'] as num?)?.toInt() ??
          0,
      scoreAfter: (map['scoreAfter'] as num?)?.toInt() ??
          (map['score_after'] as num?)?.toInt() ??
          0,
      tierAfter: map['tierAfter']?.toString() ?? map['tier_after']?.toString(),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'eventType': eventType,
        'category': category,
        'title': title,
        'body': body,
        'deltaProfile': deltaProfile,
        'deltaBehavior': deltaBehavior,
        'deltaTotal': deltaTotal,
        'profilePointsAfter': profilePointsAfter,
        'behaviorPointsAfter': behaviorPointsAfter,
        'scoreBefore': scoreBefore,
        'scoreAfter': scoreAfter,
        'tierAfter': tierAfter,
        'metadata': metadata,
      };

  factory TrustScoreEvent.fromJson(Map<String, dynamic> json) {
    return TrustScoreEvent(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      eventType: json['eventType']?.toString() ?? '',
      category: json['category']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      deltaProfile: (json['deltaProfile'] as num?)?.toInt() ?? 0,
      deltaBehavior: (json['deltaBehavior'] as num?)?.toInt() ?? 0,
      deltaTotal: (json['deltaTotal'] as num?)?.toInt() ?? 0,
      profilePointsAfter: (json['profilePointsAfter'] as num?)?.toInt(),
      behaviorPointsAfter: (json['behaviorPointsAfter'] as num?)?.toInt(),
      scoreBefore: (json['scoreBefore'] as num?)?.toInt() ?? 0,
      scoreAfter: (json['scoreAfter'] as num?)?.toInt() ?? 0,
      tierAfter: json['tierAfter']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }
}

class TrustReport {
  const TrustReport({
    required this.trustScore,
    required this.trustTier,
    required this.profilePoints,
    required this.behaviorPoints,
    required this.profilePointsMax,
    required this.behaviorPointsMax,
    required this.trustScoreMax,
    required this.updatedAt,
    required this.headline,
    required this.events,
    this.profileBreakdown,
    this.behaviorBreakdown,
  });

  final int trustScore;
  final String trustTier;
  final int profilePoints;
  final int behaviorPoints;
  final int profilePointsMax;
  final int behaviorPointsMax;
  final int trustScoreMax;
  final DateTime updatedAt;
  final String headline;
  final List<TrustScoreEvent> events;
  final TrustProfileBreakdown? profileBreakdown;
  final TrustBehaviorBreakdown? behaviorBreakdown;

  factory TrustReport.fromMap(Map<String, dynamic> map) {
    final rawEvents = map['events'];
    final events = rawEvents is List
        ? rawEvents
            .whereType<Map>()
            .map((e) => TrustScoreEvent.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <TrustScoreEvent>[];

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return TrustReport(
      trustScore: (map['trustScore'] as num?)?.toInt() ?? 0,
      trustTier: (map['trustTier'] as String?) ?? 'trusted',
      profilePoints: (map['profilePoints'] as num?)?.toInt() ?? 0,
      behaviorPoints: (map['behaviorPoints'] as num?)?.toInt() ?? 0,
      profilePointsMax: (map['profilePointsMax'] as num?)?.toInt() ?? 150,
      behaviorPointsMax: (map['behaviorPointsMax'] as num?)?.toInt() ?? 50,
      trustScoreMax: (map['trustScoreMax'] as num?)?.toInt() ?? 200,
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
      headline: map['headline']?.toString() ?? '',
      events: events,
      profileBreakdown: map['profileBreakdown'] is Map
          ? TrustProfileBreakdown.fromMap(
              Map<String, dynamic>.from(map['profileBreakdown'] as Map),
            )
          : null,
      behaviorBreakdown: map['behaviorBreakdown'] is Map
          ? TrustBehaviorBreakdown.fromMap(
              Map<String, dynamic>.from(map['behaviorBreakdown'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'trustScore': trustScore,
        'trustTier': trustTier,
        'profilePoints': profilePoints,
        'behaviorPoints': behaviorPoints,
        'profilePointsMax': profilePointsMax,
        'behaviorPointsMax': behaviorPointsMax,
        'trustScoreMax': trustScoreMax,
        'updatedAt': updatedAt.toIso8601String(),
        'headline': headline,
        'events': events.map((e) => e.toJson()).toList(),
        if (profileBreakdown != null)
          'profileBreakdown': profileBreakdown!.toJson(),
        if (behaviorBreakdown != null)
          'behaviorBreakdown': behaviorBreakdown!.toJson(),
      };

  factory TrustReport.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'];
    final events = rawEvents is List
        ? rawEvents
            .whereType<Map>()
            .map((e) => TrustScoreEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <TrustScoreEvent>[];

    return TrustReport(
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
      trustTier: (json['trustTier'] as String?) ?? 'trusted',
      profilePoints: (json['profilePoints'] as num?)?.toInt() ?? 0,
      behaviorPoints: (json['behaviorPoints'] as num?)?.toInt() ?? 0,
      profilePointsMax: (json['profilePointsMax'] as num?)?.toInt() ?? 150,
      behaviorPointsMax: (json['behaviorPointsMax'] as num?)?.toInt() ?? 50,
      trustScoreMax: (json['trustScoreMax'] as num?)?.toInt() ?? 200,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      headline: json['headline']?.toString() ?? '',
      events: events,
      profileBreakdown: json['profileBreakdown'] is Map
          ? TrustProfileBreakdown.fromMap(
              Map<String, dynamic>.from(json['profileBreakdown'] as Map),
            )
          : null,
      behaviorBreakdown: json['behaviorBreakdown'] is Map
          ? TrustBehaviorBreakdown.fromMap(
              Map<String, dynamic>.from(json['behaviorBreakdown'] as Map),
            )
          : null,
    );
  }
}
