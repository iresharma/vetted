/// Thread list preview when the last message was deleted for everyone.
const chatDeletedLastMessagePreview = 'Message deleted';

/// Tombstone copy for thread list / legacy.
const chatDeletedMessagePlaceholder = 'Message deleted';

/// Centered system notice when someone else deleted a message.
String chatDeletedByOtherMessage(String senderName) =>
    '$senderName deleted a message';

/// Centered system notice on the sender's side.
const chatDeletedByYouMessage = 'You deleted this message';

/// Fallback when replying to a message that is no longer available.
const chatReplyUnavailablePlaceholder = 'Message unavailable';

/// Quick-reaction emojis shown in the action sheet.
const chatQuickReactionEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
