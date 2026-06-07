import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:vetted_club_mobile/core/cache/local_cache.dart';
import 'package:vetted_club_mobile/core/config/app_check_bootstrap.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_thread_preview.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_thread_id.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  static const _threadsCollection = 'chat_threads';
  static const _messageLimit = 50;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _primeAppCheckIfNeeded({bool forceRefresh = false}) async {
    if (useAppCheckDebugProviders) {
      await primeAppCheckToken(forceRefresh: forceRefresh);
    }
  }

  Future<void> ensureReadyForFirestore({bool forceRefresh = false}) async {
    await _primeAppCheckIfNeeded(forceRefresh: forceRefresh);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.getIdToken(forceRefresh);
    }
  }

  Future<String> getOrCreateThread({
    required String otherUid,
    required String otherName,
    required String currentName,
  }) async {
    final currentUid = _currentUid;
    if (currentUid == null) {
      throw StateError('Must be signed in to open a chat.');
    }

    await _primeAppCheckIfNeeded();

    final threadId = buildThreadId(currentUid, otherUid);
    final ref = _firestore.collection(_threadsCollection).doc(threadId);
    final snap = await ref.get();

    if (!snap.exists) {
      final members = [currentUid, otherUid]..sort();
      await ref.set({
        'members': members,
        'memberNames': {
          currentUid: currentName,
          otherUid: otherName,
        },
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': {
          currentUid: 0,
          otherUid: 0,
        },
      });
    }

    return threadId;
  }

  Future<void> sendMessage(String threadId, String text) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _primeAppCheckIfNeeded();

    final threadRef = _firestore.collection(_threadsCollection).doc(threadId);
    final threadSnap = await threadRef.get();
    if (!threadSnap.exists) return;

    final data = threadSnap.data() ?? {};
    final members = List<String>.from(data['members'] ?? []);
    final memberNames = Map<String, dynamic>.from(data['memberNames'] ?? {});
    final currentName = memberNames[currentUid]?.toString() ?? 'Member';
    final recipientUid = members.firstWhere(
      (id) => id != currentUid,
      orElse: () => '',
    );
    if (recipientUid.isEmpty) return;

    final batch = _firestore.batch();
    final msgRef = threadRef.collection('messages').doc(_uuid.v4());

    batch.set(msgRef, {
      'senderId': currentUid,
      'senderName': currentName,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [currentUid],
    });

    batch.update(threadRef, {
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount.$currentUid': 0,
      'unreadCount.$recipientUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Cache → one-shot fetch → live snapshot listener.
  Stream<List<ChatThreadPreview>> watchThreads(String uid) {
    late StreamController<List<ChatThreadPreview>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;

    controller = StreamController<List<ChatThreadPreview>>(
      onListen: () {
        unawaited(() async {
          controller.add(LocalCache.readChatThreads(uid));

          await ensureReadyForFirestore();

          final query = _firestore
              .collection(_threadsCollection)
              .where('members', arrayContains: uid)
              .orderBy('lastMessageAt', descending: true);

          try {
            final snapshot = await query.get();
            final threads = _mapThreadDocs(snapshot.docs, uid);
            await LocalCache.writeChatThreads(uid, threads);
            if (!controller.isClosed) controller.add(threads);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('ChatService.watchThreads fetch: $e');
            }
          }

          subscription = query.snapshots().listen(
            (snapshot) async {
              final threads = _mapThreadDocs(snapshot.docs, uid);
              await LocalCache.writeChatThreads(uid, threads);
              if (!controller.isClosed) controller.add(threads);
            },
            onError: (Object error) {
              if (kDebugMode) {
                debugPrint('ChatService.watchThreads snapshot: $error');
              }
            },
          );
        }());
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  /// Cache → one-shot fetch → live snapshot listener.
  Stream<List<ChatMessage>> watchMessages(String uid, String threadId) {
    late StreamController<List<ChatMessage>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;

    controller = StreamController<List<ChatMessage>>(
      onListen: () {
        unawaited(() async {
          controller.add(LocalCache.readChatMessages(uid, threadId));

          await ensureReadyForFirestore();

          final query = _firestore
              .collection(_threadsCollection)
              .doc(threadId)
              .collection('messages')
              .orderBy('createdAt')
              .limitToLast(_messageLimit);

          try {
            final snapshot = await query.get();
            final messages = _mapMessageDocs(snapshot.docs);
            await LocalCache.writeChatMessages(uid, threadId, messages);
            if (!controller.isClosed) controller.add(messages);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('ChatService.watchMessages fetch: $e');
            }
          }

          subscription = query.snapshots().listen(
            (snapshot) async {
              final messages = _mapMessageDocs(snapshot.docs);
              await LocalCache.writeChatMessages(uid, threadId, messages);
              if (!controller.isClosed) controller.add(messages);
            },
            onError: (Object error) {
              if (kDebugMode) {
                debugPrint('ChatService.watchMessages snapshot: $error');
              }
            },
          );
        }());
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }

  List<ChatThreadPreview> _mapThreadDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String currentUid,
  ) {
    return docs.map((doc) => ChatThreadPreview.fromDoc(doc, currentUid)).toList();
  }

  List<ChatMessage> _mapMessageDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map(ChatMessage.fromDoc).toList();
  }

  Future<void> markAsRead(String threadId) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    try {
      await _firestore.collection(_threadsCollection).doc(threadId).update({
        'unreadCount.$currentUid': 0,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.markAsRead failed: $e');
      }
    }
  }
}
