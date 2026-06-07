import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

class ChatSwipeToReply extends StatefulWidget {
  const ChatSwipeToReply({
    super.key,
    required this.child,
    required this.enabled,
    required this.onReply,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback onReply;

  static const _triggerOffset = 80.0;
  static const _maxOffset = 96.0;

  @override
  State<ChatSwipeToReply> createState() => _ChatSwipeToReplyState();
}

class _ChatSwipeToReplyState extends State<ChatSwipeToReply>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _triggered = false;
  bool _horizontalDrag = false;

  late AnimationController _snapController;
  Animation<double>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: AppMotion.slideDuration,
    )..addListener(() {
        if (_snapAnimation != null) {
          setState(() => _dragOffset = _snapAnimation!.value);
        }
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _snapBack() {
    _snapAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: AppMotion.standardCurve,
    ));
    _snapController.forward(from: 0).whenComplete(() {
      _triggered = false;
      _horizontalDrag = false;
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _snapController.stop();
    _horizontalDrag = false;
    _triggered = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;

    final dx = details.delta.dx;
    final dy = details.delta.dy;

    if (!_horizontalDrag) {
      if (dx.abs() > dy.abs() && dx > 0) {
        _horizontalDrag = true;
      } else if (dy.abs() > dx.abs()) {
        return;
      }
    }

    if (!_horizontalDrag) return;

    setState(() {
      _dragOffset = (_dragOffset + dx).clamp(0.0, ChatSwipeToReply._maxOffset);
    });

    if (!_triggered && _dragOffset >= ChatSwipeToReply._triggerOffset) {
      _triggered = true;
      HapticFeedback.lightImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled || !_horizontalDrag) {
      if (_dragOffset > 0) _snapBack();
      return;
    }

    if (_triggered) {
      widget.onReply();
    }
    _snapBack();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          if (_dragOffset > 0)
            Positioned(
              left: AppSpacing.screenHorizontal,
              child: Opacity(
                opacity: (_dragOffset / ChatSwipeToReply._triggerOffset)
                    .clamp(0.0, 1.0),
                child: Icon(
                  PhosphorIconsRegular.arrowBendUpLeft,
                  size: 20,
                  color: AppColors.coral,
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
