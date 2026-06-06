import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_report.dart';

/// Hive-backed cache for member data (profile, trust, registration status).
class LocalCache {
  LocalCache._();

  static const _boxName = 'member_cache';
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _store {
    final box = _box;
    if (box == null) {
      throw StateError('LocalCache.init() must be called before use');
    }
    return box;
  }

  static String _profileDraftKey(String uid) => 'profile_draft:$uid';
  static String _registrationStatusKey(String uid) => 'registration_status:$uid';
  static String _trustReportKey(String uid, String? category) =>
      'trust_report:$uid:${category ?? 'all'}';

  static ProfileDraft? readProfileDraft(String uid) =>
      _read(_profileDraftKey(uid), ProfileDraft.fromJson);

  static Future<void> writeProfileDraft(String uid, ProfileDraft draft) =>
      _write(_profileDraftKey(uid), draft.toJson());

  static RegistrationStatus? readRegistrationStatus(String uid) =>
      _read(_registrationStatusKey(uid), RegistrationStatus.fromJson);

  static Future<void> writeRegistrationStatus(
    String uid,
    RegistrationStatus status,
  ) =>
      _write(_registrationStatusKey(uid), status.toJson());

  static TrustReport? readTrustReport(String uid, String? category) =>
      _read(_trustReportKey(uid, category), TrustReport.fromJson);

  static Future<void> writeTrustReport(
    String uid,
    String? category,
    TrustReport report,
  ) =>
      _write(_trustReportKey(uid, category), report.toJson());

  static Future<void> clearUser(String uid) async {
    final prefix = [
      'profile_draft:$uid',
      'registration_status:$uid',
      'trust_report:$uid:',
    ];
    final keys = _store.keys
        .where((key) => prefix.any((p) => key.toString().startsWith(p)))
        .toList();
    await _store.deleteAll(keys);
  }

  static T? _read<T>(
    String key,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final raw = _store.get(key);
    if (raw == null) return null;
    try {
      return parse(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _write(String key, Map<String, dynamic> json) async {
    await _store.put(key, jsonEncode(json));
  }
}
