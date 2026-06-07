import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_type.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = ChatMessageType.text,
    this.createdAt,
    this.readBy = const [],
    this.gifUrl,
    this.gifPreviewUrl,
    this.gifId,
    this.gifTitle,
    this.gifAspectRatio,
    this.replyTo,
    this.reactions = const {},
    this.hiddenFor = const [],
    this.deletedForEveryone = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final ChatMessageType type;
  final DateTime? createdAt;
  final List<String> readBy;
  final String? gifUrl;
  final String? gifPreviewUrl;
  final String? gifId;
  final String? gifTitle;
  final double? gifAspectRatio;
  final ChatReplyPreview? replyTo;
  final Map<String, String> reactions;
  final List<String> hiddenFor;
  final bool deletedForEveryone;

  bool get isFromCurrentUser =>
      senderId == FirebaseAuth.instance.currentUser?.uid;

  bool get isGif => type == ChatMessageType.gif;

  bool get isDeletedForEveryone => deletedForEveryone;

  bool isHiddenFor(String uid) => hiddenFor.contains(uid);

  bool isReadBy(String uid) => readBy.contains(uid);

  bool canDeleteForEveryone(String otherUid, {required String currentUid}) =>
      senderId == currentUid &&
      !deletedForEveryone &&
      !isReadBy(otherUid);

  bool canHideForMe(String currentUid) =>
      !isHiddenFor(currentUid) && !deletedForEveryone;

  bool isOwnMessage(String currentUid) => senderId == currentUid;

  bool canUnsendForMe(String currentUid) =>
      isOwnMessage(currentUid) && canHideForMe(currentUid);

  String? reactionFor(String uid) => reactions[uid];

  /// Emoji → count, preserving insertion order of first occurrence.
  List<MapEntry<String, int>> get reactionSummary {
    final counts = <String, int>{};
    for (final emoji in reactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return counts.entries.toList();
  }

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: ChatMessageType.fromFirestore(data['type'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
      gifUrl: data['gifUrl'] as String?,
      gifPreviewUrl: data['gifPreviewUrl'] as String?,
      gifId: data['gifId'] as String?,
      gifTitle: data['gifTitle'] as String?,
      gifAspectRatio: (data['gifAspectRatio'] as num?)?.toDouble(),
      replyTo: data['replyTo'] != null
          ? ChatReplyPreview.fromFirestore(
              Map<String, dynamic>.from(data['replyTo'] as Map),
            )
          : null,
      reactions: Map<String, String>.from(
        (data['reactions'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            {},
      ),
      hiddenFor: List<String>.from(data['hiddenFor'] ?? []),
      deletedForEveryone: data['deletedForEveryone'] as bool? ?? false,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: ChatMessageType.fromFirestore(json['type'] as String?),
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw)
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      gifUrl: json['gifUrl'] as String?,
      gifPreviewUrl: json['gifPreviewUrl'] as String?,
      gifId: json['gifId'] as String?,
      gifTitle: json['gifTitle'] as String?,
      gifAspectRatio: (json['gifAspectRatio'] as num?)?.toDouble(),
      replyTo: json['replyTo'] != null
          ? ChatReplyPreview.fromJson(
              Map<String, dynamic>.from(json['replyTo'] as Map),
            )
          : null,
      reactions: Map<String, String>.from(
        (json['reactions'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            {},
      ),
      hiddenFor: List<String>.from(json['hiddenFor'] ?? []),
      deletedForEveryone: json['deletedForEveryone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': type.firestoreValue,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'readBy': readBy,
        if (gifUrl != null) 'gifUrl': gifUrl,
        if (gifPreviewUrl != null) 'gifPreviewUrl': gifPreviewUrl,
        if (gifId != null) 'gifId': gifId,
        if (gifTitle != null) 'gifTitle': gifTitle,
        if (gifAspectRatio != null) 'gifAspectRatio': gifAspectRatio,
        if (replyTo != null && replyTo!.isValid)
          'replyTo': replyTo!.toJson(),
        if (reactions.isNotEmpty) 'reactions': reactions,
        if (hiddenFor.isNotEmpty) 'hiddenFor': hiddenFor,
        if (deletedForEveryone) 'deletedForEveryone': true,
      };
}
