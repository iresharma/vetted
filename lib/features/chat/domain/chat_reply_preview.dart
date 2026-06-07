import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_type.dart';

class ChatReplyPreview {
  const ChatReplyPreview({
    required this.messageId,
    required this.senderName,
    required this.text,
    this.type = ChatMessageType.text,
  });

  final String messageId;
  final String senderName;
  final String text;
  final ChatMessageType type;

  factory ChatReplyPreview.fromMessage(ChatMessage message) {
    return ChatReplyPreview(
      messageId: message.id,
      senderName: message.senderName,
      text: message.isGif ? chatGifLastMessagePreview : message.text,
      type: message.type,
    );
  }

  factory ChatReplyPreview.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const ChatReplyPreview(
        messageId: '',
        senderName: '',
        text: '',
      );
    }
    return ChatReplyPreview(
      messageId: data['messageId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: ChatMessageType.fromFirestore(data['type'] as String?),
    );
  }

  factory ChatReplyPreview.fromJson(Map<String, dynamic> json) {
    return ChatReplyPreview(
      messageId: json['messageId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: ChatMessageType.fromFirestore(json['type'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'messageId': messageId,
        'senderName': senderName,
        'text': text,
        'type': type.firestoreValue,
      };

  Map<String, dynamic> toJson() => toFirestore();

  bool get isValid => messageId.isNotEmpty;
}
