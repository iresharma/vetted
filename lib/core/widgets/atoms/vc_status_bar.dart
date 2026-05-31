import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Decorative iOS-style status bar used in design previews.
class VcStatusBar extends StatelessWidget {
  const VcStatusBar({super.key, this.time = '9:41'});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: AppTypography.supporting(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Row(
            children: [
              Icon(Icons.signal_cellular_4_bar,
                  size: 14, color: AppColors.textPrimary),
              SizedBox(width: 4),
              Icon(Icons.wifi, size: 14, color: AppColors.textPrimary),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 16, color: AppColors.textPrimary),
            ],
          ),
        ],
      ),
    );
  }
}
