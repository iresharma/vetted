import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.sending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _focused = false;

  static const _sendSize = 32.0;
  static const _inputVerticalPadding = 11.0;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
        ),
      ),
    );
  }
}
