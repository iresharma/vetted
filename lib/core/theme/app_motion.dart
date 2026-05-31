import 'package:flutter/animation.dart';

/// Motion tokens from design.html section 08.
abstract final class AppMotion {
  static const pressDuration = Duration(milliseconds: 60);
  static const slideDuration = Duration(milliseconds: 280);
  static const popDuration = Duration(milliseconds: 260);
  static const heartbeatDuration = Duration(milliseconds: 500);
  static const xpFillDuration = Duration(milliseconds: 500);
  static const xpFillDelay = Duration(milliseconds: 300);
  static const staggerDelay = Duration(milliseconds: 45);

  static const standardCurve = Cubic(0.4, 0.0, 0.2, 1.0);
  static const popCurve = Cubic(0.34, 1.4, 0.64, 1.0);
}
