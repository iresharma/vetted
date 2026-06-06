class ProfileDraft {
  const ProfileDraft({
    this.verifiedName,
    this.verifiedAge,
    this.trustScore = 0,
    this.trustTier = 'trusted',
    this.profilePoints = 0,
    this.behaviorPoints = 0,
    this.isLive = false,
    this.values = const {},
    this.extras = const {},
  });

  final String? verifiedName;
  final int? verifiedAge;
  final int trustScore;
  final String trustTier;
  final int profilePoints;
  final int behaviorPoints;
  final bool isLive;

  /// UI field id -> display/raw value.
  final Map<String, dynamic> values;

  /// profile_extras keys.
  final Map<String, dynamic> extras;

  /// User-chosen display name from biodata (preferred for UI greetings).
  String? get displayName {
    final display = values['display_name']?.toString().trim();
    if (display != null && display.isNotEmpty) return display;
    return null;
  }

  static bool _isPlaceholderVerifiedName(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized == 'verified member' || normalized == 'verified';
  }

  /// First name for headers — display name first, then DigiLocker legal name.
  String get firstName {
    final display = displayName;
    if (display != null) return display.split(RegExp(r'\s+')).first;
    final verified = verifiedName?.trim();
    if (verified != null &&
        verified.isNotEmpty &&
        !_isPlaceholderVerifiedName(verified)) {
      return verified.split(RegExp(r'\s+')).first;
    }
    return 'Member';
  }

  /// Full name for cards — display name first, then DigiLocker legal name.
  String get preferredName {
    final display = displayName;
    if (display != null) return display;
    final verified = verifiedName?.trim();
    if (verified != null &&
        verified.isNotEmpty &&
        !_isPlaceholderVerifiedName(verified)) {
      return verified;
    }
    return 'Member';
  }

  ProfileDraft copyWith({
    String? verifiedName,
    int? verifiedAge,
    int? trustScore,
    String? trustTier,
    int? profilePoints,
    int? behaviorPoints,
    bool? isLive,
    Map<String, dynamic>? values,
    Map<String, dynamic>? extras,
  }) {
    return ProfileDraft(
      verifiedName: verifiedName ?? this.verifiedName,
      verifiedAge: verifiedAge ?? this.verifiedAge,
      trustScore: trustScore ?? this.trustScore,
      trustTier: trustTier ?? this.trustTier,
      profilePoints: profilePoints ?? this.profilePoints,
      behaviorPoints: behaviorPoints ?? this.behaviorPoints,
      isLive: isLive ?? this.isLive,
      values: values ?? this.values,
      extras: extras ?? this.extras,
    );
  }

  factory ProfileDraft.fromMap(Map<String, dynamic> map) {
    final extrasRaw = map['profileExtras'] ?? map['profile_extras'];
    final extras = extrasRaw is Map
        ? Map<String, dynamic>.from(extrasRaw)
        : <String, dynamic>{};

    final values = <String, dynamic>{};

    dynamic pick(String camel, String snake) => map[camel] ?? map[snake];

    void set(String id, dynamic value, {dynamic labelFrom}) {
      if (value == null) return;
      if (value is List && value.isEmpty) return;
      if (value is String && value.isEmpty) return;
      values[id] = labelFrom ?? value;
    }

    set('display_name', pick('displayName', 'display_name'));
    set('gender', pick('gender', 'gender'),
        labelFrom: _genderLabel(pick('gender', 'gender')));
    set('city', pick('city', 'city'));
    set('home_state', pick('homeState', 'home_state'));
    final height = pick('heightCm', 'height_cm');
    if (height != null) set('height_cm', height.toString());
    set('body_type', pick('bodyType', 'body_type'),
        labelFrom: _bodyTypeLabel(pick('bodyType', 'body_type')));
    set('marital_status', pick('maritalStatus', 'marital_status'),
        labelFrom: _maritalLabel(pick('maritalStatus', 'marital_status')));
    set('has_children', pick('hasChildren', 'has_children'),
        labelFrom: _hasChildrenLabel(pick('hasChildren', 'has_children')));
    set('grew_up_abroad', pick('grewUpAbroad', 'grew_up_abroad'),
        labelFrom: _grewUpAbroadLabel(pick('grewUpAbroad', 'grew_up_abroad')));
    set('job_title', pick('profession', 'profession'));
    set('field_of_work', pick('fieldOfWork', 'field_of_work'));
    set('employment_type', pick('employmentType', 'employment_type'));
    set('company', pick('company', 'company'));
    set('education_level', pick('educationLevel', 'education_level'));
    set('college', pick('college', 'college'));
    set('income_bracket', pick('incomeBracket', 'income_bracket'));
    set('work_mode', pick('workMode', 'work_mode'),
        labelFrom: _workModeLabel(pick('workMode', 'work_mode')));
    set('faith', pick('faith', 'faith'), labelFrom: _faithLabel(pick('faith', 'faith')));
    set('religiosity', pick('religiosity', 'religiosity'));
    set('community', pick('community', 'community'));
    set('sub_caste', pick('subCaste', 'sub_caste'));
    set('mother_tongue', pick('motherTongue', 'mother_tongue'));
    final languages = pick('languagesSpoken', 'languages_spoken');
    if (languages is List) {
      values['languages_spoken'] = List<String>.from(languages);
    }
    set('manglik_status', pick('manglikStatus', 'manglik_status'));
    set('rashi', pick('rashi', 'rashi'));
    set('nakshatra', pick('nakshatra', 'nakshatra'));
    set('gotra', pick('gotra', 'gotra'));
    final birthTime = pick('birthTime', 'birth_time');
    if (birthTime != null) {
      values['birth_time'] = birthTime.toString();
    }
    set('birth_place', pick('birthPlace', 'birth_place'));
    set('living_arrangement_post_marriage',
        pick('livingArrangementPostMarriage', 'living_arrangement_post_marriage'));
    set('father_occupation', pick('fatherOccupation', 'father_occupation'));
    set('mother_occupation', pick('motherOccupation', 'mother_occupation'));
    set('siblings', pick('siblings', 'siblings'));
    set('family_location', pick('familyLocation', 'family_location'));
    set('family_structure', pick('familyStructure', 'family_structure'),
        labelFrom: _familyStructureLabel(pick('familyStructure', 'family_structure')));
    set('family_involvement', pick('familyInvolvement', 'family_involvement'),
        labelFrom: _familyInvolvementLabel(
            pick('familyInvolvement', 'family_involvement')));
    set('horoscope_matters', pick('horoscopeMatters', 'horoscope_matters'),
        labelFrom: _horoscopeLabel(pick('horoscopeMatters', 'horoscope_matters')));
    set('diet', pick('diet', 'diet'), labelFrom: _dietLabel(pick('diet', 'diet')));
    set('drinking', pick('drinking', 'drinking'),
        labelFrom: _drinkingLabel(pick('drinking', 'drinking')));
    set('smoking', pick('smoking', 'smoking'),
        labelFrom: _smokingLabel(pick('smoking', 'smoking')));
    set('marriage_timeline', pick('marriageTimeline', 'marriage_timeline'),
        labelFrom: _timelineLabel(pick('marriageTimeline', 'marriage_timeline')));
    set('wants_children', pick('kidsPreference', 'kids_preference'),
        labelFrom: _kidsLabel(pick('kidsPreference', 'kids_preference')));
    set('willing_to_relocate', pick('willingToRelocate', 'willing_to_relocate'),
        labelFrom: _relocateLabel(pick('willingToRelocate', 'willing_to_relocate')));
    set('open_to_inter_faith', pick('openToInterFaith', 'open_to_inter_faith'),
        labelFrom: _triBoolLabel(pick('openToInterFaith', 'open_to_inter_faith')));
    set('open_to_inter_community',
        pick('openToInterCommunity', 'open_to_inter_community'),
        labelFrom:
            _triBoolLabel(pick('openToInterCommunity', 'open_to_inter_community')));

    final prompt1 = pick('prompt1A', 'prompt_1_a');
    if (prompt1 != null) values['prompt_1'] = prompt1;
    final prompt2 = pick('prompt2A', 'prompt_2_a');
    if (prompt2 != null) values['prompt_2'] = prompt2;
    final prompt3 = pick('prompt3A', 'prompt_3_a');
    if (prompt3 != null) values['prompt_3'] = prompt3;

    final photos = pick('photoUrls', 'photo_urls');
    if (photos is List) {
      values['photo_urls'] = List<String>.from(photos);
    }
    final interests = pick('interests', 'interests');
    if (interests is List) {
      values['interests'] = List<String>.from(interests);
    }
    set('voice_note_url', pick('voiceNoteUrl', 'voice_note_url'));

    for (final entry in extras.entries) {
      values[entry.key] = _normalizeExtraValue(entry.key, entry.value);
    }

    return ProfileDraft(
      verifiedName: pick('verifiedName', 'verified_name') as String?,
      verifiedAge: (pick('verifiedAge', 'verified_age') as num?)?.toInt(),
      trustScore: _pickInt(map, 'trustScore', 'trust_score') ??
          _pickInt(map, 'completenessPct', 'completeness_pct') ??
          0,
      trustTier: (pick('trustTier', 'trust_tier') as String?) ?? 'trusted',
      profilePoints:
          _pickInt(map, 'profilePoints', 'profile_points') ?? 0,
      behaviorPoints:
          _pickInt(map, 'behaviorPoints', 'behavior_points') ?? 0,
      isLive: pick('isLive', 'is_live') == true,
      values: values,
      extras: extras,
    );
  }

  static dynamic _normalizeExtraValue(String key, dynamic value) {
    if (key == 'weekend_vibe') {
      if (value is String && value.isNotEmpty) return [value];
      if (value is List) {
        return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    }
    return value;
  }

  static int? _pickInt(Map<String, dynamic> map, String camel, String snake) {
    final value = map[camel] ?? map[snake];
    return (value as num?)?.toInt();
  }

  Map<String, dynamic> toJson() => {
        'verifiedName': verifiedName,
        'verifiedAge': verifiedAge,
        'trustScore': trustScore,
        'trustTier': trustTier,
        'profilePoints': profilePoints,
        'behaviorPoints': behaviorPoints,
        'isLive': isLive,
        'values': values,
        'extras': extras,
      };

  factory ProfileDraft.fromJson(Map<String, dynamic> json) {
    return ProfileDraft(
      verifiedName: json['verifiedName'] as String?,
      verifiedAge: (json['verifiedAge'] as num?)?.toInt(),
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
      trustTier: (json['trustTier'] as String?) ?? 'trusted',
      profilePoints: (json['profilePoints'] as num?)?.toInt() ?? 0,
      behaviorPoints: (json['behaviorPoints'] as num?)?.toInt() ?? 0,
      isLive: json['isLive'] == true,
      values: json['values'] is Map
          ? Map<String, dynamic>.from(json['values'] as Map)
          : const {},
      extras: json['extras'] is Map
          ? Map<String, dynamic>.from(json['extras'] as Map)
          : const {},
    );
  }
}

String? _genderLabel(dynamic v) => switch (v) {
      'man' => 'Man',
      'woman' => 'Woman',
      'non_binary' => 'Non-binary',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v?.toString(),
    };

String? _maritalLabel(dynamic v) => switch (v) {
      'never_married' => 'Never married',
      'divorced' => 'Divorced',
      'widowed' => 'Widowed',
      'separated' => 'Separated',
      _ => v?.toString(),
    };

String? _bodyTypeLabel(dynamic v) => switch (v) {
      'slim' => 'Slim',
      'average' => 'Average',
      'athletic' => 'Athletic',
      'heavyset' => 'Heavyset',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v?.toString(),
    };

String? _hasChildrenLabel(dynamic v) => switch (v) {
      'no' => 'No',
      'yes_1' => 'Yes — 1 child',
      'yes_2' => 'Yes — 2 children',
      'yes_3_plus' => 'Yes — 3 or more',
      _ => v?.toString(),
    };

String? _grewUpAbroadLabel(dynamic v) {
  if (v == true) return 'Yes — currently abroad';
  if (v == false) return 'No, grew up in India';
  return null;
}

String? _workModeLabel(dynamic v) => switch (v) {
      'in_office' => 'In-office',
      'remote' => 'Remote',
      'hybrid' => 'Hybrid',
      'prefer_not_to_say' => 'Varies',
      _ => v?.toString(),
    };

String? _faithLabel(dynamic v) => switch (v) {
      'hindu' => 'Hindu',
      'muslim' => 'Muslim',
      'sikh' => 'Sikh',
      'christian' => 'Christian',
      'jain' => 'Jain',
      'buddhist' => 'Buddhist',
      'agnostic' => 'Agnostic',
      'atheist' => 'Atheist',
      'other' => 'Other',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v?.toString(),
    };

String? _familyStructureLabel(dynamic v) => switch (v) {
      'nuclear' => 'Nuclear',
      'joint' => 'Joint',
      'open_to_either' => 'Open to either',
      _ => v?.toString(),
    };

String? _familyInvolvementLabel(dynamic v) => switch (v) {
      'parents_leading' => 'Parents are actively involved and leading',
      'i_decide_they_know' => "They know I'm looking — I make the final call",
      'private_for_now' => 'This is private for now',
      _ => v?.toString(),
    };

String? _horoscopeLabel(dynamic v) {
  if (v == true) return 'Yes, it matters to me';
  if (v == false) return 'No';
  return null;
}

String? _dietLabel(dynamic v) => switch (v) {
      'vegetarian' => 'Vegetarian',
      'non_vegetarian' => 'Non-vegetarian',
      'eggetarian' => 'Eggetarian',
      'vegan' => 'Vegan',
      'jain' => 'Jain (strict vegetarian)',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v?.toString(),
    };

String? _drinkingLabel(dynamic v) => switch (v) {
      'never' => 'Never',
      'socially' => 'Socially',
      'regularly' => 'Regularly',
      'prefer_not_to_say' => 'Prefer not to say',
      _ => v?.toString(),
    };

String? _smokingLabel(dynamic v) => _drinkingLabel(v);

String? _timelineLabel(dynamic v) => switch (v) {
      'within_6_months' => 'Within 6 months',
      'within_1_year' => 'Within 1 year',
      '1_to_2_years' => '1 to 2 years',
      '2_to_3_years' => '2 to 3 years',
      'exploring' => 'Still exploring — no fixed timeline',
      _ => v?.toString(),
    };

String? _kidsLabel(dynamic v) => switch (v) {
      'want_kids' => 'Yes — I definitely want kids',
      'open_to_kids' => 'Open to it',
      'do_not_want' => "No — I don't want children",
      'have_kids' => 'I already have children',
      'prefer_not_to_say' => 'Not sure yet',
      _ => v?.toString(),
    };

String? _relocateLabel(dynamic v) {
  if (v == true) return "Yes — I'm flexible";
  if (v == false) return 'No — I need to stay in my city';
  return 'Possibly — depends on where';
}

String? _triBoolLabel(dynamic v) {
  if (v == true) return 'Yes';
  if (v == false) return 'No';
  return 'Depends on the person';
}
