import 'package:flutter_test/flutter_test.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_message_type.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';

void main() {
  group('ChatMessage actions', () {
    const otherUid = 'user-b';
    const currentUid = 'user-a';

    test('isReadBy returns true when uid is in readBy', () {
      const message = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        readBy: [currentUid, otherUid],
      );

      expect(message.isReadBy(otherUid), isTrue);
      expect(message.isReadBy('unknown'), isFalse);
    });

    test('canDeleteForEveryone requires unread recipient', () {
      const unread = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        readBy: [currentUid],
      );
      const read = ChatMessage(
        id: 'm2',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        readBy: [currentUid, otherUid],
      );
      const received = ChatMessage(
        id: 'm3',
        senderId: otherUid,
        senderName: 'Sam',
        text: 'hey',
        readBy: [otherUid],
      );

      expect(unread.canDeleteForEveryone(otherUid, currentUid: currentUid), isTrue);
      expect(read.canDeleteForEveryone(otherUid, currentUid: currentUid), isFalse);
      expect(received.canDeleteForEveryone(otherUid, currentUid: currentUid), isFalse);
    });

    test('canHideForMe works for any non-deleted message', () {
      const own = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
      );
      const received = ChatMessage(
        id: 'm2',
        senderId: otherUid,
        senderName: 'Sam',
        text: 'hey',
      );

      expect(own.canHideForMe(currentUid), isTrue);
      expect(received.canHideForMe(currentUid), isTrue);
      expect(own.canUnsendForMe(currentUid), isTrue);
      expect(received.canUnsendForMe(currentUid), isFalse);
    });

    test('isHiddenFor checks hiddenFor list', () {
      const message = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        hiddenFor: [currentUid],
      );

      expect(message.isHiddenFor(currentUid), isTrue);
      expect(message.isHiddenFor(otherUid), isFalse);
    });

    test('reactionSummary groups emojis with counts', () {
      const message = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        reactions: {
          'user-a': '❤️',
          'user-b': '❤️',
          'user-c': '👍',
        },
      );

      final summary = message.reactionSummary;
      expect(summary.length, 2);

      final heart = summary.firstWhere((e) => e.key == '❤️');
      expect(heart.value, 2);
    });

    test('replyTo round-trips through json', () {
      const message = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        type: ChatMessageType.gif,
        gifUrl: 'https://example.com/gif.gif',
        gifId: 'gif123',
      );

      final preview = ChatReplyPreview.fromMessage(message);
      expect(preview.messageId, 'm1');
      expect(preview.text, 'GIF');
      expect(preview.type, ChatMessageType.gif);

      final withReply = ChatMessage(
        id: 'm2',
        senderId: otherUid,
        senderName: 'Sam',
        text: 'replying',
        replyTo: preview,
      );

      final restored = ChatMessage.fromJson(withReply.toJson());
      expect(restored.replyTo?.messageId, 'm1');
      expect(restored.replyTo?.text, 'GIF');
    });

    test('deletedForEveryone serializes', () {
      const message = ChatMessage(
        id: 'm1',
        senderId: currentUid,
        senderName: 'Alex',
        text: 'hello',
        deletedForEveryone: true,
      );

      final restored = ChatMessage.fromJson(message.toJson());
      expect(restored.deletedForEveryone, isTrue);
      expect(restored.isDeletedForEveryone, isTrue);
    });
  });

  group('ChatMessage gif', () {
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
