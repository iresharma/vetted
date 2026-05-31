import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/app_motion.dart';

/// NeoPOP offset shadow + press interaction from design.html section 03/08.
class NeoPopPressable extends StatefulWidget {
  const NeoPopPressable({
    super.key,
    required this.shadowColor,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.borderRadius = BorderRadius.zero,
    this.idleShadowOffset = 4,
    this.pressedShadowOffset = 1,
    this.pressedTranslate = 3,
  });

  final Color shadowColor;
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final BorderRadius borderRadius;
  final double idleShadowOffset;
  final double pressedShadowOffset;
  final double pressedTranslate;

  @override
  State<NeoPopPressable> createState() => _NeoPopPressableState();
}

class _NeoPopPressableState extends State<NeoPopPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final shadowOffset =
        _pressed ? widget.pressedShadowOffset : widget.idleShadowOffset;
    final translate = _pressed ? widget.pressedTranslate : 0.0;
    final maxExtent = widget.idleShadowOffset + widget.pressedTranslate;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapUp: widget.enabled
          ? (_) {
              _setPressed(false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.enabled ? () => _setPressed(false) : null,
      child: Padding(
        padding: EdgeInsets.only(right: maxExtent, bottom: maxExtent),
        child: CustomPaint(
          painter: _NeoPopShadowPainter(
            color: widget.shadowColor,
            offset: Offset(shadowOffset, shadowOffset),
            borderRadius: widget.borderRadius,
          ),
          child: AnimatedContainer(
            duration: AppMotion.pressDuration,
            curve: Curves.ease,
            transform: Matrix4.translationValues(translate, translate, 0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _NeoPopShadowPainter extends CustomPainter {
  _NeoPopShadowPainter({
    required this.color,
    required this.offset,
    required this.borderRadius,
  });

  final Color color;
  final Offset offset;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    canvas.drawRRect(rect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NeoPopShadowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.offset != offset ||
        oldDelegate.borderRadius != borderRadius;
  }
}
