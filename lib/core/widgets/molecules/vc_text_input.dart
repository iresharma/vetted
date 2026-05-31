import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VcTextInput extends StatefulWidget {
  const VcTextInput({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
  });

  const VcTextInput.phone({
    super.key,
    this.controller,
    this.placeholder = '98765 43210',
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  })  : keyboardType = TextInputType.phone,
        textInputAction = TextInputAction.done,
        obscureText = false,
        maxLines = 1,
        minLines = null;

  const VcTextInput.prompt({
    super.key,
    this.controller,
    required this.label,
    this.placeholder = 'Be real...',
    this.onChanged,
    this.autofocus = false,
  })  : keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        maxLines = 4,
        minLines = 3,
        onSubmitted = null;

  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final bool autofocus;

  @override
  State<VcTextInput> createState() => _VcTextInputState();
}

class _VcTextInputState extends State<VcTextInput> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label != null && widget.maxLines > 1) {
      return _PromptTextarea(
        controller: widget.controller,
        label: widget.label!,
        placeholder: widget.placeholder,
        focusNode: _focusNode,
        focused: _focused,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.eyebrow()),
          const SizedBox(height: 6),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.s1,
            borderRadius: AppRadius.r12,
            border: Border.all(
              color: _focused ? AppColors.violet : AppColors.border,
              width: _focused ? 1.5 : 0.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            style: AppTypography.body(),
            cursorColor: AppColors.violet,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTypography.body(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              isDense: true,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ],
    );
  }
}

class VcPhoneInput extends StatefulWidget {
  const VcPhoneInput({
    super.key,
    this.controller,
    this.placeholder = '98765 43210',
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  State<VcPhoneInput> createState() => _VcPhoneInputState();
}

class _VcPhoneInputState extends State<VcPhoneInput> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s1,
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: _focused ? AppColors.violet : AppColors.border,
          width: _focused ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              '+91',
              style: AppTypography.body(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.border,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.body(),
              cursorColor: AppColors.violet,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: AppTypography.body(color: AppColors.textMuted),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.only(
                  right: AppSpacing.md,
                  top: 14,
                  bottom: 14,
                ),
                isDense: true,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptTextarea extends StatelessWidget {
  const _PromptTextarea({
    required this.label,
    required this.placeholder,
    required this.focusNode,
    required this.focused,
    this.controller,
    this.onChanged,
    this.maxLines = 4,
    this.minLines = 3,
  });

  final String label;
  final String? placeholder;
  final FocusNode focusNode;
  final bool focused;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s1,
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: focused ? AppColors.violet : AppColors.border,
          width: focused ? 1.5 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.eyebrow().copyWith(
                fontStyle: FontStyle.italic,
                letterSpacing: 0.05 * 11,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLines,
              minLines: minLines,
              style: AppTypography.supporting(color: AppColors.textSecondary)
                  .copyWith(fontSize: 14),
              cursorColor: AppColors.violet,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle:
                    AppTypography.supporting(color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
