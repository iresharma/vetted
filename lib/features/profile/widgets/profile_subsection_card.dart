import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_validator.dart';

class ProfileSubsectionCard extends StatelessWidget {
  const ProfileSubsectionCard({
    super.key,
    required this.subsection,
    required this.values,
    required this.child,
  });

  final ProfileSubsection subsection;
  final Map<String, dynamic> values;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final requiredFields = subsection.fields
        .where((f) => f.status != ProfileFieldStatus.optional)
        .toList();
    final done = requiredFields.where((f) {
      return ProfileValidator.isFieldFilled(f, values[f.id]);
    }).length;
    final total = requiredFields.length;
    final complete = total > 0 && done >= total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: VcSoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subsection.label,
                    style: AppTypography.labelCaps(),
                  ),
                ),
                Icon(
                  complete
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: complete ? AppColors.mint : AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
