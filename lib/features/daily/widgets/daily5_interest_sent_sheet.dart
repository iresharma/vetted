import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class Daily5InterestSentSheet extends StatelessWidget {
  const Daily5InterestSentSheet({super.key, required this.name});

  final String name;

  static Future<void> show(
    BuildContext context, {
    required String name,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Daily5InterestSentSheet(name: name),
    );
  }

  String get _firstName {
    final clean = name.replaceFirst(RegExp(r'^\[TEST\]\s*'), '');
    return clean.split(RegExp(r'[\s,]')).first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.violet.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                PhosphorIconsRegular.paperPlaneTilt,
                color: AppColors.violet,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Interest sent', style: AppTypography.headline()),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We let $_firstName know. If they say yes too, you\'ll match instantly.',
              style: AppTypography.body(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            VcButton(
              label: 'Keep browsing →',
              variant: VcButtonVariant.muted,
              expanded: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
