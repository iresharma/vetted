import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class VcOtpInputRow extends StatefulWidget {
  const VcOtpInputRow({
    super.key,
    this.length = 6,
    this.autofocus = false,
    this.onCompleted,
    this.onChanged,
  });

  final int length;
  final bool autofocus;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<VcOtpInputRow> createState() => VcOtpInputRowState();
}

class VcOtpInputRowState extends State<VcOtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get value => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _notify();
  }

  void _notify({bool completed = false}) {
    widget.onChanged?.call(value);
    if (completed && value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  void _onChanged(int index, String raw) {
    if (raw.length > 1) {
      _handlePaste(raw);
      return;
    }

    final isLastBox = index == widget.length - 1;
    if (raw.isNotEmpty && !isLastBox) {
      _focusNodes[index + 1].requestFocus();
    }

    _notify(completed: isLastBox && raw.isNotEmpty);
  }

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }

    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _notify();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final nextIndex = digits.length.clamp(0, widget.length - 1);
    _focusNodes[nextIndex].requestFocus();
    _notify(completed: digits.length >= widget.length);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return _OtpBox(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) => _onChanged(index, value),
          onKeyEvent: (event) => _onKeyEvent(index, event),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final active = widget.focusNode.hasFocus;

    return Focus(
      onKeyEvent: (_, event) => widget.onKeyEvent(event),
      child: AnimatedContainer(
        duration: AppMotion.pressDuration,
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.s1,
          borderRadius: AppRadius.r10,
          border: Border.all(
            color: active ? AppColors.violet : AppColors.border,
            width: active ? 1.5 : 0.5,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x4D000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
            if (active)
              const BoxShadow(
                color: AppColors.violetDark,
                offset: Offset(3, 3),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTypography.otpDigit(),
          cursorColor: AppColors.violet,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
