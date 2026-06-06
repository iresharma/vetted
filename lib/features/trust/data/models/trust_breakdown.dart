class TrustBreakdownItem {
  const TrustBreakdownItem({
    required this.key,
    required this.label,
    required this.filled,
    required this.pointsEarned,
    required this.pointsPossible,
  });

  final String key;
  final String label;
  final bool filled;
  final double pointsEarned;
  final double pointsPossible;

  factory TrustBreakdownItem.fromMap(Map<String, dynamic> map) {
    return TrustBreakdownItem(
      key: map['key']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      filled: map['filled'] == true,
      pointsEarned: (map['pointsEarned'] as num?)?.toDouble() ?? 0,
      pointsPossible: (map['pointsPossible'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'filled': filled,
        'pointsEarned': pointsEarned,
        'pointsPossible': pointsPossible,
      };
}

class TrustBreakdownSection {
  const TrustBreakdownSection({
    required this.id,
    required this.label,
    required this.description,
    required this.pointsEarned,
    required this.pointsMax,
    required this.items,
  });

  final String id;
  final String label;
  final String description;
  final double pointsEarned;
  final int pointsMax;
  final List<TrustBreakdownItem> items;

  List<TrustBreakdownItem> get missingItems =>
      items.where((item) => !item.filled).toList();

  factory TrustBreakdownSection.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    return TrustBreakdownSection(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      pointsEarned: (map['pointsEarned'] as num?)?.toDouble() ?? 0,
      pointsMax: (map['pointsMax'] as num?)?.toInt() ?? 0,
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => TrustBreakdownItem.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'description': description,
        'pointsEarned': pointsEarned,
        'pointsMax': pointsMax,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class TrustProfileBreakdown {
  const TrustProfileBreakdown({
    required this.total,
    required this.max,
    required this.sections,
  });

  final int total;
  final int max;
  final List<TrustBreakdownSection> sections;

  factory TrustProfileBreakdown.fromMap(Map<String, dynamic> map) {
    final rawSections = map['sections'];
    return TrustProfileBreakdown(
      total: (map['total'] as num?)?.toInt() ?? 0,
      max: (map['max'] as num?)?.toInt() ?? 150,
      sections: rawSections is List
          ? rawSections
              .whereType<Map>()
              .map((e) => TrustBreakdownSection.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'max': max,
        'sections': sections.map((e) => e.toJson()).toList(),
      };
}

class TrustBehaviorItem {
  const TrustBehaviorItem({
    required this.id,
    required this.label,
    required this.description,
    required this.currentValue,
    required this.pointsEarned,
    required this.pointsMax,
  });

  final String id;
  final String label;
  final String description;
  final String currentValue;
  final int pointsEarned;
  final int pointsMax;

  factory TrustBehaviorItem.fromMap(Map<String, dynamic> map) {
    return TrustBehaviorItem(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      currentValue: map['currentValue']?.toString() ?? '',
      pointsEarned: (map['pointsEarned'] as num?)?.toInt() ?? 0,
      pointsMax: (map['pointsMax'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'description': description,
        'currentValue': currentValue,
        'pointsEarned': pointsEarned,
        'pointsMax': pointsMax,
      };
}

class TrustBehaviorBreakdown {
  const TrustBehaviorBreakdown({
    required this.total,
    required this.max,
    required this.items,
  });

  final int total;
  final int max;
  final List<TrustBehaviorItem> items;

  factory TrustBehaviorBreakdown.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    return TrustBehaviorBreakdown(
      total: (map['total'] as num?)?.toInt() ?? 0,
      max: (map['max'] as num?)?.toInt() ?? 50,
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => TrustBehaviorItem.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'max': max,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

String formatTrustPoints(num value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}
