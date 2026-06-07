import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/chat/utils/chat_formatters.dart';

class ChatDateSeparator extends StatelessWidget {
  const ChatDateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xxs + 2,
            ),
            child: Text(
              ChatFormatters.dateSeparator(date),
              style: AppTypography.eyebrow(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
