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
import 'package:vetted_club_mobile/features/chat/domain/chat_message_type.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_constants.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';

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
    String? otherPhotoUrl,
    String? currentPhotoUrl,
  }) async {
    final currentUid = _currentUid;
    if (currentUid == null) {
      throw StateError('Must be signed in to open a chat.');
    }

    await _primeAppCheckIfNeeded();

    final threadId = buildThreadId(currentUid, otherUid);
    final ref = _firestore.collection(_threadsCollection).doc(threadId);
    final snap = await ref.get();

    final photoUpdates = <String, String>{};
    final otherUrl = otherPhotoUrl?.trim();
    final currentUrl = currentPhotoUrl?.trim();
    if (otherUrl != null && otherUrl.isNotEmpty) {
      photoUpdates[otherUid] = otherUrl;
    }
    if (currentUrl != null && currentUrl.isNotEmpty) {
      photoUpdates[currentUid] = currentUrl;
    }

    if (!snap.exists) {
      final members = [currentUid, otherUid]..sort();
      await ref.set({
        'members': members,
        'memberNames': {
          currentUid: currentName,
          otherUid: otherName,
        },
        if (photoUpdates.isNotEmpty) 'memberPhotoUrls': photoUpdates,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': {
          currentUid: 0,
          otherUid: 0,
        },
      });
    } else if (photoUpdates.isNotEmpty) {
      await ref.update({
        for (final entry in photoUpdates.entries)
          'memberPhotoUrls.${entry.key}': entry.value,
      });
    }

    return threadId;
  }

  Future<void> ensureMemberPhoto({
    required String threadId,
    required String memberUid,
    required String photoUrl,
  }) async {
    final url = photoUrl.trim();
    if (url.isEmpty) return;

    try {
      await _firestore.collection(_threadsCollection).doc(threadId).update({
        'memberPhotoUrls.$memberUid': url,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.ensureMemberPhoto failed: $e');
      }
    }
  }

  Future<void> sendMessage(
    String threadId,
    String text, {
    ChatReplyPreview? replyTo,
  }) async {
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
      if (replyTo != null && replyTo.isValid) 'replyTo': replyTo.toFirestore(),
    });

    batch.update(threadRef, {
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount.$currentUid': 0,
      'unreadCount.$recipientUid': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> sendGifMessage(
    String threadId, {
    required String gifUrl,
    required String gifId,
    String? gifPreviewUrl,
    String? gifTitle,
    double? gifAspectRatio,
    ChatReplyPreview? replyTo,
  }) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    final url = gifUrl.trim();
    if (url.isEmpty || gifId.trim().isEmpty) return;

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
      'type': ChatMessageType.gif.firestoreValue,
      'senderId': currentUid,
      'senderName': currentName,
      'text': '',
      'gifUrl': url,
      'gifId': gifId,
      if (gifPreviewUrl != null && gifPreviewUrl.isNotEmpty)
        'gifPreviewUrl': gifPreviewUrl,
      if (gifTitle != null && gifTitle.isNotEmpty) 'gifTitle': gifTitle,
      if (gifAspectRatio != null) 'gifAspectRatio': gifAspectRatio,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [currentUid],
      if (replyTo != null && replyTo.isValid) 'replyTo': replyTo.toFirestore(),
    });

    batch.update(threadRef, {
      'lastMessage': chatGifLastMessagePreview,
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
    final currentUid = _currentUid;
    return docs
        .map(ChatMessage.fromDoc)
        .where(
          (message) =>
              currentUid == null || !message.isHiddenFor(currentUid),
        )
        .toList();
  }

  Future<void> markAsRead(
    String threadId, {
    required String otherUserId,
  }) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    try {
      await _firestore.collection(_threadsCollection).doc(threadId).update({
        'unreadCount.$currentUid': 0,
      });

      final threadRef = _firestore.collection(_threadsCollection).doc(threadId);
      final messagesSnap = await threadRef
          .collection('messages')
          .orderBy('createdAt')
          .limitToLast(_messageLimit)
          .get();

      final batch = _firestore.batch();
      var hasUpdates = false;

      for (final doc in messagesSnap.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String? ?? '';
        final readBy = List<String>.from(data['readBy'] ?? []);
        if (senderId == otherUserId && !readBy.contains(currentUid)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([currentUid]),
          });
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.markAsRead failed: $e');
      }
    }
  }

  Future<void> hideMessageForMe(String threadId, String messageId) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    await _primeAppCheckIfNeeded();

    try {
      await _firestore
          .collection(_threadsCollection)
          .doc(threadId)
          .collection('messages')
          .doc(messageId)
          .update({
        'hiddenFor': FieldValue.arrayUnion([currentUid]),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.hideMessageForMe failed: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteForEveryone(
    String threadId,
    String messageId, {
    required String otherUserId,
    required ChatMessage message,
  }) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    if (!message.canDeleteForEveryone(otherUserId, currentUid: currentUid)) {
      throw StateError('Message cannot be deleted for everyone.');
    }

    await _primeAppCheckIfNeeded();

    final threadRef = _firestore.collection(_threadsCollection).doc(threadId);
    final msgRef = threadRef.collection('messages').doc(messageId);

    try {
      await msgRef.update({'deletedForEveryone': true});

      final threadSnap = await threadRef.get();
      if (!threadSnap.exists) return;

      final lastMessage = threadSnap.data()?['lastMessage'] as String? ?? '';
      final previewText = message.isGif ? chatGifLastMessagePreview : message.text;
      if (lastMessage == previewText) {
        await threadRef.update({
          'lastMessage': chatDeletedLastMessagePreview,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.deleteForEveryone failed: $e');
      }
      rethrow;
    }
  }

  Future<void> setReaction(
    String threadId,
    String messageId,
    String emoji,
  ) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    await _primeAppCheckIfNeeded();

    try {
      await _firestore
          .collection(_threadsCollection)
          .doc(threadId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$currentUid': emoji,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.setReaction failed: $e');
      }
      rethrow;
    }
  }

  Future<void> removeReaction(String threadId, String messageId) async {
    final currentUid = _currentUid;
    if (currentUid == null) return;

    await _primeAppCheckIfNeeded();

    try {
      await _firestore
          .collection(_threadsCollection)
          .doc(threadId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$currentUid': FieldValue.delete(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatService.removeReaction failed: $e');
      }
      rethrow;
    }
  }

  Future<void> toggleReaction(
    String threadId,
    String messageId,
    String emoji, {
    String? currentReaction,
  }) async {
    if (currentReaction == emoji) {
      await removeReaction(threadId, messageId);
    } else {
      await setReaction(threadId, messageId, emoji);
    }
  }
}
