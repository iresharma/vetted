import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Semi-circular trust gauge, score range 0–[maxScore].
class VcTrustGauge extends StatelessWidget {
  const VcTrustGauge({
    super.key,
    required this.score,
    this.maxScore = 200,
    this.size = 240,
  });

  final int score;
  final int maxScore;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = (score / maxScore).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size * 0.58,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 0.52),
            painter: _TrustGaugePainter(progress: progress),
          ),
          Positioned(
            bottom: size * 0.05,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: AppTypography.price(
                    color: AppColors.textPrimary,
                    fontSize: 52,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'of $maxScore',
                  style: AppTypography.supporting(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Positioned(
            left: 4,
            bottom: 0,
            child: Text(
              '0',
              style: AppTypography.chip(color: AppColors.textMuted),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            child: Text(
              '$maxScore',
              style: AppTypography.chip(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustGaugePainter extends CustomPainter {
  _TrustGaugePainter({required this.progress});

  final double progress;

  static const _startAngle = math.pi;
  static const _sweepAngle = math.pi;
  static const _stroke = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = size.width / 2 - _stroke;

    final track = Paint()
      ..color = AppColors.s3
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle,
      false,
      track,
    );

    if (progress <= 0) return;

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.violet, AppColors.amber],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle * progress,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrustGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
