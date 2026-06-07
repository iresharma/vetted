import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';
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

  static String _valuesQuizStatusKey(String uid) => 'values_quiz_status:$uid';
  static String _chatThreadsKey(String uid) => 'chat_threads:$uid';
  static String _chatMessagesKey(String uid, String threadId) =>
      'chat_messages:$uid:$threadId';

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

  static String? readValuesQuizStatus(String uid) => _store.get(_valuesQuizStatusKey(uid));

  static Future<void> writeValuesQuizStatus(String uid, String status) =>
      _store.put(_valuesQuizStatusKey(uid), status);

  static TrustReport? readTrustReport(String uid, String? category) =>
      _read(_trustReportKey(uid, category), TrustReport.fromJson);

  static Future<void> writeTrustReport(
    String uid,
    String? category,
    TrustReport report,
  ) =>
      _write(_trustReportKey(uid, category), report.toJson());

  static List<ChatThreadPreview> readChatThreads(String uid) =>
      _readList(_chatThreadsKey(uid), ChatThreadPreview.fromJson);

  static Future<void> writeChatThreads(
    String uid,
    List<ChatThreadPreview> threads,
  ) =>
      _writeList(
        _chatThreadsKey(uid),
        threads.map((t) => t.toJson()).toList(),
      );

  static List<ChatMessage> readChatMessages(String uid, String threadId) =>
      _readList(_chatMessagesKey(uid, threadId), ChatMessage.fromJson);

  static Future<void> writeChatMessages(
    String uid,
    String threadId,
    List<ChatMessage> messages,
  ) =>
      _writeList(
        _chatMessagesKey(uid, threadId),
        messages.map((m) => m.toJson()).toList(),
      );

  static Future<void> clearUser(String uid) async {
    final prefix = [
      'profile_draft:$uid',
      'registration_status:$uid',
      'values_quiz_status:$uid',
      'trust_report:$uid:',
      'chat_threads:$uid',
      'chat_messages:$uid:',
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

  static List<T> _readList<T>(
    String key,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final raw = _store.get(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .map((item) => parse(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    await _store.put(key, jsonEncode(items));
  }
}
