import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/chat/domain/chat_reply_preview.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.onGifTap,
    this.sending = false,
    this.gifEnabled = true,
    this.replyPreview,
    this.onCancelReply,
    this.focusNode,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onGifTap;
  final bool sending;
  final bool gifEnabled;
  final ChatReplyPreview? replyPreview;
  final VoidCallback? onCancelReply;
  final FocusNode? focusNode;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _hasText = false;
  bool _focused = false;

  static const _sendSize = 32.0;
  static const _inputVerticalPadding = 11.0;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next != _hasText) setState(() => _hasText = next);
  }

  void _handleSend() {
    if (widget.sending || !_hasText) return;
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _hasText && !widget.sending;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm + 2,
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.replyPreview != null && widget.replyPreview!.isValid)
                _ReplyPreviewBar(
                  replyPreview: widget.replyPreview!,
                  onCancel: widget.onCancelReply,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              if (widget.onGifTap != null) ...[
                Semantics(
                  button: true,
                  enabled: widget.gifEnabled && !widget.sending,
                  label: 'Send GIF',
                  child: SizedBox(
                    width: _sendSize,
                    height: _sendSize,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: widget.gifEnabled && !widget.sending
                            ? widget.onGifTap
                            : null,
                        borderRadius: AppRadius.r8,
                        child: Center(
                          child: Icon(
                            PhosphorIconsRegular.gif,
                            size: 18,
                            color: widget.gifEnabled && !widget.sending
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.s1,
                    borderRadius: AppRadius.r12,
                    border: Border.all(
                      color: _focused
                          ? AppColors.coral.withValues(alpha: 0.45)
                          : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    style: AppTypography.body(),
                    cursorColor: AppColors.coral,
                    decoration: InputDecoration(
                      hintText: 'Say something real…',
                      hintStyle: AppTypography.body(color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: _inputVerticalPadding,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Semantics(
                button: true,
                enabled: canSend,
                label: 'Send message',
                child: SizedBox(
                  width: _sendSize,
                  height: _sendSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: canSend ? AppColors.coralDim : AppColors.s2,
                      borderRadius: AppRadius.r8,
                      border: Border.all(
                        color: canSend
                            ? AppColors.coral.withValues(alpha: 0.35)
                            : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: canSend ? _handleSend : null,
                        borderRadius: AppRadius.r8,
                        child: Center(
                          child: widget.sending
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.coral,
                                  ),
                                )
                              : Icon(
                                  PhosphorIconsRegular.paperPlaneTilt,
                                  size: 15,
                                  color: canSend
                                      ? AppColors.coral
                                      : AppColors.textMuted,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyPreviewBar extends StatelessWidget {
  const _ReplyPreviewBar({
    required this.replyPreview,
    this.onCancel,
  });

  final ChatReplyPreview replyPreview;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s1,
          borderRadius: AppRadius.r8,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 40,
              margin: const EdgeInsets.only(left: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyPreview.senderName,
                      style: AppTypography.statCaption(
                        color: AppColors.coral,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      replyPreview.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.supporting(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onCancel != null)
              IconButton(
                onPressed: onCancel,
                icon: Icon(
                  PhosphorIconsRegular.x,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
