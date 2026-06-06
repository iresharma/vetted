import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_mode.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_edit_close_dialog.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_edit_section_sheet.dart';

/// Step indicator for the 4-step profile creation flow.
class ProfileStepHeader extends ConsumerWidget {
  const ProfileStepHeader({
    super.key,
    required this.stepIndex,
    this.totalSteps = 4,
  });

  /// Zero-based index of the current step (-1 hides pips).
  final int stepIndex;
  final int totalSteps;

  /// Space reserved on the right for the floating sign-out control in onboarding.
  static const _signOutReserve = 88.0;
  static const _trustMax = 200;
  static const _profileTrustMax = 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trustScore = ref.watch(profileTrustScoreProvider);
    final profilePoints = ref.watch(profilePointsProvider);
    final draft = ref.watch(profileDraftProvider).value;
    final trustTier = draft?.trustTier;
    final progress = trustScore / _trustMax;
    final showSteps = stepIndex >= 0;
    final isEdit = ref.watch(profileFlowModeProvider) == ProfileFlowMode.edit;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        isEdit ? 16 : _signOutReserve,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSteps) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${stepIndex + 1} of $totalSteps',
                        style: AppTypography.eyebrow(color: AppColors.violet),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$profilePoints / $_profileTrustMax profile · $trustScore trust',
                        style: AppTypography.chip(color: AppColors.amber),
                      ),
                    ],
                  ),
                ),
                if (isEdit) ...[
                  const SizedBox(width: 8),
                  _EditHeaderActions(
                    onSections: () => ProfileEditSectionSheet.show(context),
                    onClose: () => ProfileEditCloseDialog.show(
                      context: context,
                      ref: ref,
                    ),
                  ),
                ] else if (trustTier != null) ...[
                  VcTrustBadge.trustTier(trustTier),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(totalSteps, (index) {
                final filled = index <= stepIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.violet : AppColors.s3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ] else ...[
            VcXpBar(
              progress: progress.clamp(0, 1),
              label: 'Trust $trustScore / $_trustMax',
              showPercentage: false,
            ),
          ],
        ],
      ),
    );
  }
}

class _EditHeaderActions extends StatelessWidget {
  const _EditHeaderActions({
    required this.onSections,
    required this.onClose,
  });

  final VoidCallback onSections;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: onSections,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sections',
            style: AppTypography.supporting(color: AppColors.violet)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Material(
          color: AppColors.s3,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                PhosphorIconsRegular.x,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
