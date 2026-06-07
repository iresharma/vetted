import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThreadPreview {
  const ChatThreadPreview({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ChatThreadPreview.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String currentUid,
  ) {
    final data = doc.data() ?? {};
    final members = List<String>.from(data['members'] ?? []);
    final otherUid = members.firstWhere(
      (id) => id != currentUid,
      orElse: () => '',
    );
    final names = Map<String, dynamic>.from(data['memberNames'] ?? {});
    final unreadMap = Map<String, dynamic>.from(data['unreadCount'] ?? {});

    return ChatThreadPreview(
      id: doc.id,
      otherUserId: otherUid,
      otherUserName: names[otherUid]?.toString() ?? 'Unknown',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: (unreadMap[currentUid] as num?)?.toInt() ?? 0,
    );
  }

  factory ChatThreadPreview.fromJson(Map<String, dynamic> json) {
    final lastMessageAtRaw = json['lastMessageAt'];
    return ChatThreadPreview(
      id: json['id'] as String? ?? '',
      otherUserId: json['otherUserId'] as String? ?? '',
      otherUserName: json['otherUserName'] as String? ?? 'Unknown',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: lastMessageAtRaw is String
          ? DateTime.tryParse(lastMessageAtRaw)
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'otherUserId': otherUserId,
        'otherUserName': otherUserName,
        'lastMessage': lastMessage,
        if (lastMessageAt != null)
          'lastMessageAt': lastMessageAt!.toIso8601String(),
        'unreadCount': unreadCount,
      };
}
