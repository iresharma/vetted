enum ProfileFieldStatus { required, optional, conditional }

enum ProfileFieldType {
  text,
  number,
  singleSelect,
  multiSelect,
  prompt,
  photoUpload,
  time,
  citySearch,
}

enum ProfileFieldStorage { column, extras }

class ShowIfRule {
  const ShowIfRule({
    required this.field,
    this.equals,
    this.notEquals,
  });

  final String field;
  final String? equals;
  final String? notEquals;

  factory ShowIfRule.fromJson(Map<String, dynamic> json) {
    return ShowIfRule(
      field: json['field'] as String,
      equals: json['equals'] as String?,
      notEquals: json['not_equals'] as String?,
    );
  }
}

class ProfileField {
  const ProfileField({
    required this.id,
    required this.label,
    required this.type,
    required this.status,
    this.dbKey,
    this.storage = ProfileFieldStorage.column,
    this.options = const [],
    this.showIf,
    this.promptText,
    this.maxChars,
    this.min,
    this.max,
    this.minCount,
    this.maxCount,
    this.maxSelections,
    this.maxSeconds,
  });

  final String id;
  final String label;
  final ProfileFieldType type;
  final ProfileFieldStatus status;
  final String? dbKey;
  final ProfileFieldStorage storage;
  final List<String> options;
  final ShowIfRule? showIf;
  final String? promptText;
  final int? maxChars;
  final int? min;
  final int? max;
  final int? minCount;
  final int? maxCount;
  final int? maxSelections;
  final int? maxSeconds;

  String get effectiveDbKey => dbKey ?? id;

  bool get isRequired =>
      status == ProfileFieldStatus.required ||
      status == ProfileFieldStatus.conditional;

  factory ProfileField.fromJson(
    Map<String, dynamic> json, {
    String? dbKey,
    ProfileFieldStorage storage = ProfileFieldStorage.column,
  }) {
    final rawOptions = json['options'];
    return ProfileField(
      id: json['id'] as String,
      label: json['label'] as String,
      type: _parseType(json['type'] as String),
      status: _parseStatus(json['status'] as String? ?? 'optional'),
      dbKey: dbKey ?? json['db_key'] as String?,
      storage: storage,
      options: rawOptions is List
          ? rawOptions.map((e) => e.toString()).toList()
          : const [],
      showIf: json['show_if'] is Map<String, dynamic>
          ? ShowIfRule.fromJson(json['show_if'] as Map<String, dynamic>)
          : null,
      promptText: json['prompt_text'] as String?,
      maxChars: (json['max_chars'] as num?)?.toInt(),
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
      minCount: (json['min_count'] as num?)?.toInt(),
      maxCount: (json['max_count'] as num?)?.toInt(),
      maxSelections: (json['max_selections'] as num?)?.toInt(),
      maxSeconds: (json['max_seconds'] as num?)?.toInt(),
    );
  }
}

class ProfileSubsection {
  const ProfileSubsection({
    required this.id,
    required this.label,
    required this.fields,
    this.gateField,
  });

  final String id;
  final String label;
  final List<ProfileField> fields;
  final String? gateField;

  factory ProfileSubsection.fromJson(
    Map<String, dynamic> json,
    List<ProfileField> fields,
  ) {
    return ProfileSubsection(
      id: json['id'] as String,
      label: json['label'] as String,
      fields: fields,
      gateField: json['gate_field'] as String?,
    );
  }
}

class ProfileSection {
  const ProfileSection({
    required this.id,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.xpWeight,
    required this.fields,
    this.subsections = const [],
  });

  final String id;
  final int step;
  final String title;
  final String subtitle;
  final int xpWeight;
  final List<ProfileField> fields;
  final List<ProfileSubsection> subsections;

  List<ProfileField> get allFields {
    if (subsections.isEmpty) return fields;
    return [
      for (final sub in subsections) ...sub.fields,
    ];
  }

  factory ProfileSection.fromJson(Map<String, dynamic> json) {
    final rawSubsections = json['subsections'];
    final subsections = <ProfileSubsection>[];
    final topFields = <ProfileField>[];

    if (rawSubsections is List) {
      for (final raw in rawSubsections) {
        if (raw is! Map<String, dynamic>) continue;
        final rawFields = raw['fields'];
        final fields = rawFields is List
            ? rawFields
                .whereType<Map<String, dynamic>>()
                .map((f) => ProfileField.fromJson(f))
                .toList()
            : <ProfileField>[];
        subsections.add(ProfileSubsection.fromJson(raw, fields));
      }
    } else {
      final rawFields = json['fields'];
      if (rawFields is List) {
        topFields.addAll(
          rawFields
              .whereType<Map<String, dynamic>>()
              .map((f) => ProfileField.fromJson(f)),
        );
      }
    }

    return ProfileSection(
      id: json['id'] as String,
      step: (json['step'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      xpWeight: (json['xp_weight'] as num?)?.toInt() ?? 25,
      fields: topFields,
      subsections: subsections,
    );
  }
}

class ProfileSchema {
  const ProfileSchema({
    required this.version,
    required this.requiredForLive,
    required this.sections,
  });

  final int version;
  final List<String> requiredForLive;
  final List<ProfileSection> sections;

  ProfileSection? sectionById(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }

  ProfileField? fieldById(String id) {
    for (final section in sections) {
      for (final field in section.allFields) {
        if (field.id == id) return field;
      }
    }
    return null;
  }

  factory ProfileSchema.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    return ProfileSchema(
      version: (json['schema_version'] as num?)?.toInt() ?? 1,
      requiredForLive: (json['required_for_live'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sections: rawSections is List
          ? rawSections
              .whereType<Map<String, dynamic>>()
              .map(ProfileSection.fromJson)
              .toList()
          : const [],
    );
  }
}

ProfileFieldType _parseType(String raw) => switch (raw) {
      'text' => ProfileFieldType.text,
      'number' => ProfileFieldType.number,
      'single_select' => ProfileFieldType.singleSelect,
      'multi_select' => ProfileFieldType.multiSelect,
      'prompt' => ProfileFieldType.prompt,
      'photo_upload' => ProfileFieldType.photoUpload,
      'time' => ProfileFieldType.time,
      'city_search' => ProfileFieldType.citySearch,
      _ => ProfileFieldType.text,
    };

ProfileFieldStatus _parseStatus(String raw) => switch (raw) {
      'required' => ProfileFieldStatus.required,
      'conditional' => ProfileFieldStatus.conditional,
      _ => ProfileFieldStatus.optional,
    };
