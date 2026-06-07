enum ChatMessageType {
  text,
  gif;

  static ChatMessageType fromFirestore(String? raw) {
    return switch (raw) {
      'gif' => ChatMessageType.gif,
      _ => ChatMessageType.text,
    };
  }

  String get firestoreValue => name;
}

/// Thread list preview label for GIF messages.
const chatGifLastMessagePreview = 'GIF';
