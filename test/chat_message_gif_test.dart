import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_type.dart';

void main() {
  group('ChatMessage', () {
    test('fromJson defaults missing type to text', () {
      final message = ChatMessage.fromJson({
        'id': 'm1',
        'senderId': 'u1',
        'senderName': 'Alex',
        'text': 'hello',
      });

      expect(message.type, ChatMessageType.text);
      expect(message.isGif, isFalse);
    });

    test('toJson round-trips gif fields', () {
      const message = ChatMessage(
        id: 'm2',
        senderId: 'u1',
        senderName: 'Alex',
        text: '',
        type: ChatMessageType.gif,
        gifUrl: 'https://media.giphy.com/gif.gif',
        gifPreviewUrl: 'https://media.giphy.com/preview.webp',
        gifId: 'abc123',
        gifTitle: 'wave',
        gifAspectRatio: 1.5,
      );

      final restored = ChatMessage.fromJson(message.toJson());

      expect(restored.type, ChatMessageType.gif);
      expect(restored.gifUrl, message.gifUrl);
      expect(restored.gifPreviewUrl, message.gifPreviewUrl);
      expect(restored.gifId, message.gifId);
      expect(restored.gifTitle, message.gifTitle);
      expect(restored.gifAspectRatio, message.gifAspectRatio);
    });
  });
}
