import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class Daily5MatchCelebration {
  Daily5MatchCelebration._();

  static Future<void> show(
    BuildContext context, {
    required String otherName,
    required String otherInitial,
    required String yourInitial,
    required VoidCallback onSayHi,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss match celebration',
      barrierColor: AppColors.bg.withValues(alpha: 0.94),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, _, __) {
        return Material(
          type: MaterialType.transparency,
          child: VcMatchOverlay(
            otherName: otherName,
            otherInitial: otherInitial,
            yourInitial: yourInitial,
            onSayHi: () {
              Navigator.of(ctx).pop();
              onSayHi();
            },
          ),
        );
      },
      transitionBuilder: (ctx, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
