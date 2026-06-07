import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_flutter_sdk/dto/giphy_media.dart';
import 'package:vetted_club_mobile/core/providers/auth_providers.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/data/models/chat_message.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';
import 'package:vetted_club_mobile/features/chat/providers/chat_providers.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_composer.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_giphy_picker_sheet.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_message_action_sheet.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_message_list.dart';
import 'package:vetted_club_mobile/features/chat/utils/chat_giphy_payload.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_thread_header.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_full_profile_sheet.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  final String threadId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _composerFocusNode = FocusNode();
  bool _sending = false;
  bool _loadingProfile = false;
  int _lastMessageCount = 0;
  ChatMessage? _replyTarget;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  void _markAsRead() {
    ChatService.instance.markAsRead(
      widget.threadId,
      otherUserId: widget.otherUserId,
    );
  }

  ChatReplyPreview? get _replyPreview {
    final target = _replyTarget;
    if (target == null) return null;
    return ChatReplyPreview.fromMessage(target);
  }

  void _setReplyTarget(ChatMessage message) {
    setState(() => _replyTarget = message);
    _composerFocusNode.requestFocus();
  }

  void _clearReplyTarget() {
    if (_replyTarget == null) return;
    setState(() => _replyTarget = null);
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: AppMotion.slideDuration,
          curve: AppMotion.standardCurve,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _send() async {
    if (_sending) return;
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    final replyTo = _replyPreview;

    setState(() => _sending = true);
    try {
      await ChatService.instance.sendMessage(
        widget.threadId,
        text,
        replyTo: replyTo,
      );
      _textController.clear();
      _clearReplyTarget();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openGiphyPicker() async {
    if (_sending) return;

    await ChatGiphyPickerSheet.show(
      context,
      onMediaSelect: _sendGif,
    );
  }

  Future<void> _sendGif(GiphyMedia media) async {
    if (_sending) return;

    final payload = ChatGiphyPayload.fromMedia(media);
    if (!payload.isValid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send that GIF. Try another.')),
      );
      return;
    }

    final replyTo = _replyPreview;

    setState(() => _sending = true);
    try {
      await ChatService.instance.sendGifMessage(
        widget.threadId,
        gifUrl: payload.gifUrl,
        gifId: payload.gifId,
        gifPreviewUrl: payload.gifPreviewUrl,
        gifTitle: payload.gifTitle,
        gifAspectRatio: payload.gifAspectRatio,
        replyTo: replyTo,
      );
      _clearReplyTarget();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _openProfile() async {
    if (_loadingProfile) return;

    setState(() => _loadingProfile = true);
    try {
      final profile = await ref.read(
        chatMatchProfileProvider(widget.otherUserId).future,
      );
      if (!mounted) return;
      await Daily5FullProfileSheet.show(
        context,
        profile: profile,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _openMessageActions(ChatMessage message) async {
    final currentUid = ref.read(authUidProvider);
    if (currentUid == null) return;

    final isOwn = message.isOwnMessage(currentUid);
    final canDelete = message.canDeleteForEveryone(
      widget.otherUserId,
      currentUid: currentUid,
    );

    await ChatMessageActionSheet.show(
      context,
      message: message,
      onReply: () => _setReplyTarget(message),
      onReaction: (emoji) => _toggleReaction(message, emoji),
      onHideForMe: message.canHideForMe(currentUid)
          ? () => _hideForMe(message)
          : null,
      hideForMeLabel: isOwn ? 'Unsend for me' : 'Remove for me',
      onDeleteForEveryone: isOwn && !message.deletedForEveryone
          ? () => _deleteForEveryone(message)
          : null,
      deleteForEveryoneEnabled: canDelete,
      onDeleteForEveryoneDisabled: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This message was already read and cannot be deleted for everyone.',
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleReaction(ChatMessage message, String emoji) async {
    final currentUid = ref.read(authUidProvider);
    if (currentUid == null) return;

    try {
      await ChatService.instance.toggleReaction(
        widget.threadId,
        message.id,
        emoji,
        currentReaction: message.reactionFor(currentUid),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not react: $e')),
      );
    }
  }

  Future<void> _hideForMe(ChatMessage message) async {
    try {
      await ChatService.instance.hideMessageForMe(
        widget.threadId,
        message.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not unsend: $e')),
      );
    }
  }

  Future<void> _deleteForEveryone(ChatMessage message) async {
    try {
      await ChatService.instance.deleteForEveryone(
        widget.threadId,
        message.id,
        otherUserId: widget.otherUserId,
        message: message,
      );
    } on StateError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This message was already read and cannot be deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  void _maybeScrollToBottom(int messageCount) {
    if (messageCount == _lastMessageCount) return;
    _lastMessageCount = messageCount;
    _scrollToBottom(animated: messageCount > 1);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.threadId));

    ref.listen(chatMessagesStreamProvider(widget.threadId), (previous, next) {
      if (next.hasValue) _markAsRead();
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const VcStatusBar(),
          ChatThreadHeader(
            otherUserName: widget.otherUserName,
            otherUserPhotoUrl: widget.otherUserPhotoUrl,
            onViewProfile: _openProfile,
            loadingProfile: _loadingProfile,
          ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _maybeScrollToBottom(messages.length);

                if (messages.isEmpty) {
                  return ChatEmptyConversation(
                    otherUserName: widget.otherUserName,
                    otherUserPhotoUrl: widget.otherUserPhotoUrl,
                  );
                }

                return ChatMessageList(
                  messages: messages,
                  scrollController: _scrollController,
                  otherUserId: widget.otherUserId,
                  onMessageReply: _setReplyTarget,
                  onMessageLongPress: _openMessageActions,
                );
              },
              loading: () => const Center(
                child: VcLoadingIndicator(compact: true),
              ),
              error: (_, __) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Text(
                    'Could not load messages. Check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
          ChatComposer(
            controller: _textController,
            focusNode: _composerFocusNode,
            onSend: _send,
            onGifTap: _openGiphyPicker,
            sending: _sending,
            replyPreview: _replyPreview,
            onCancelReply: _clearReplyTarget,
          ),
        ],
      ),
    );
  }
}
