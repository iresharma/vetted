import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.createdAt,
    this.readBy = const [],
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? createdAt;
  final List<String> readBy;

  bool get isFromCurrentUser =>
      senderId == FirebaseAuth.instance.currentUser?.uid;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw)
          : null,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'readBy': readBy,
      };
}
