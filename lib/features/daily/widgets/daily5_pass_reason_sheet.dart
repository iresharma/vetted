import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class Daily5PassOption {
  const Daily5PassOption({
    required this.label,
    required this.passReason,
    this.passReasonField,
  });

  final String label;
  final String passReason;
  final String? passReasonField;
}

const daily5PassOptions = [
  Daily5PassOption(
    label: 'Different timeline',
    passReason: 'different_timeline',
    passReasonField: 'marriage_timeline',
  ),
  Daily5PassOption(
    label: 'Lifestyle mismatch',
    passReason: 'lifestyle_mismatch',
    passReasonField: 'diet',
  ),
  Daily5PassOption(
    label: 'Family values don\'t align',
    passReason: 'family_values',
    passReasonField: 'family_involvement',
  ),
  Daily5PassOption(
    label: 'Location won\'t work',
    passReason: 'location',
    passReasonField: 'city',
  ),
  Daily5PassOption(
    label: 'Not my type',
    passReason: 'not_my_type',
  ),
  Daily5PassOption(
    label: 'Other',
    passReason: 'other',
  ),
];

class Daily5PassReasonSheet extends StatelessWidget {
  const Daily5PassReasonSheet({
    super.key,
    required this.onSelect,
  });

  final ValueChanged<Daily5PassOption> onSelect;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Daily5PassOption> onSelect,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.s1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Daily5PassReasonSheet(onSelect: onSelect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.s3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Why are you passing?',
                style: AppTypography.title().copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'This helps us personalise your future picks.',
                style: AppTypography.supporting(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              for (final option in daily5PassOptions) ...[
                VcButton.muted(
                  label: option.label,
                  expanded: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(option);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
