import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// The Vetted Club mark — rounded square with V stroke and violet dot.
class VcLogoMark extends StatelessWidget {
  const VcLogoMark({
    super.key,
    this.size = 84,
    this.animated = false,
    this.violetBorder = false,
    this.pulseDot = false,
  });

  final double size;
  final bool animated;
  final bool violetBorder;
  final bool pulseDot;

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return _AnimatedLogoMark(
        size: size,
        violetBorder: violetBorder,
        pulseDot: pulseDot,
      );
    }

    if (pulseDot) {
      return _PulsingLogoMark(size: size, violetBorder: violetBorder);
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _VcLogoPainter(
          violetBorder: violetBorder,
        ),
      ),
    );
  }
}

class _PulsingLogoMark extends StatefulWidget {
  const _PulsingLogoMark({
    required this.size,
    required this.violetBorder,
  });

  final double size;
  final bool violetBorder;

  @override
  State<_PulsingLogoMark> createState() => _PulsingLogoMarkState();
}

class _PulsingLogoMarkState extends State<_PulsingLogoMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _VcLogoPainter(
              violetBorder: widget.violetBorder,
              dotScale: 1 + 0.3 * _pulse.value,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedLogoMark extends StatefulWidget {
  const _AnimatedLogoMark({
    required this.size,
    required this.violetBorder,
    required this.pulseDot,
  });

  final double size;
  final bool violetBorder;
  final bool pulseDot;

  @override
  State<_AnimatedLogoMark> createState() => _AnimatedLogoMarkState();
}

class _AnimatedLogoMarkState extends State<_AnimatedLogoMark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _reveal;
  late Animation<double> _leftStroke;
  late Animation<double> _rightStroke;
  late Animation<double> _dot;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Cubic(0.34, 1.2, 0.64, 1)),
    );
    _leftStroke = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.65, curve: Curves.ease),
    );
    _rightStroke = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.ease),
    );
    _dot = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 1.0, curve: Cubic(0.34, 1.6, 0.64, 1)),
    );

    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.scale(
            scale: 0.75 + _reveal.value * 0.25,
            alignment: Alignment.center,
            child: Opacity(
              opacity: _reveal.value.clamp(0.0, 1.0),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _VcLogoPainter(
                    leftProgress: _leftStroke.value,
                    rightProgress: _rightStroke.value,
                    dotProgress: _dot.value,
                    violetBorder: widget.violetBorder,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VcLogoPainter extends CustomPainter {
  _VcLogoPainter({
    this.leftProgress = 1,
    this.rightProgress = 1,
    this.dotProgress = 1,
    this.violetBorder = false,
    this.dotScale = 1,
  });

  final double leftProgress;
  final double rightProgress;
  final double dotProgress;
  final bool violetBorder;
  final double dotScale;

  static const _viewSize = 80.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewSize;

    canvas.save();
    canvas.scale(scale);

    final bg = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 80, 80),
      const Radius.circular(18),
    );
    canvas.drawRRect(bg, Paint()..color = AppColors.s2);
    canvas.drawRRect(
      bg,
      Paint()
        ..color = violetBorder ? AppColors.violet : AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = violetBorder ? 1.5 : 1,
    );

    final strokePaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawPartialLine(
      canvas,
      strokePaint,
      const Offset(20, 22),
      const Offset(40, 58),
      leftProgress,
    );
    _drawPartialLine(
      canvas,
      strokePaint,
      const Offset(60, 22),
      const Offset(40, 58),
      rightProgress,
    );

    if (dotProgress > 0) {
      canvas.drawCircle(
        const Offset(40, 58),
        3.5 * dotScale,
        Paint()..color = AppColors.violet.withValues(alpha: dotProgress),
      );
    }

    canvas.restore();
  }

  void _drawPartialLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    double progress,
  ) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    final metrics = path.computeMetrics().first;
    canvas.drawPath(
      metrics.extractPath(0, metrics.length * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VcLogoPainter oldDelegate) {
    return oldDelegate.leftProgress != leftProgress ||
        oldDelegate.rightProgress != rightProgress ||
        oldDelegate.dotProgress != dotProgress ||
        oldDelegate.violetBorder != violetBorder ||
        oldDelegate.dotScale != dotScale;
  }
}
