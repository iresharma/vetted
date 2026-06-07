import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/providers/chat_providers.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_composer.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_thread_header.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_message_bubble.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  final String threadId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppMotion.slideDuration,
          curve: AppMotion.standardCurve,
        );
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
          ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _scrollToBottom();
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hi to ${widget.otherUserName}',
                      style: AppTypography.body(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: messages.length,
                  itemBuilder: (_, index) =>
                      ChatMessageBubble(message: messages[index]),
                );
              },
              loading: () => const Center(
                child: VcLoadingIndicator(compact: true),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Could not load messages',
                  style: AppTypography.body(color: AppColors.textSecondary),
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
