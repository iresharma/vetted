import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Step row used in multi-step intro screens (verification, profile, etc.).
class VcFlowStepRow extends StatelessWidget {
  const VcFlowStepRow({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final int stepNumber;
  final String title;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $stepNumber · $title',
                  style: AppTypography.body().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTypography.supporting(color: AppColors.textSecondary)
                      .copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
