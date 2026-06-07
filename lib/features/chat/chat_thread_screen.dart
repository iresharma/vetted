import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/providers/chat_providers.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_composer.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_message_list.dart';
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
  bool _sending = false;
  bool _loadingProfile = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    ChatService.instance.markAsRead(widget.threadId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

    setState(() => _sending = true);
    try {
      await ChatService.instance.sendMessage(widget.threadId, text);
      _textController.clear();
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

  void _maybeScrollToBottom(int messageCount) {
    if (messageCount == _lastMessageCount) return;
    _lastMessageCount = messageCount;
    _scrollToBottom(animated: messageCount > 1);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.threadId));

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
            onSend: _send,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}
