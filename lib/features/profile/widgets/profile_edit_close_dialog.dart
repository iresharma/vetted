import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/profile_edit_finish.dart';

enum _ProfileEditCloseChoice { keepEditing, discard, save }

/// Asks whether to save, discard, or keep editing the biodata editor.
abstract final class ProfileEditCloseDialog {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final choice = await showDialog<_ProfileEditCloseChoice>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: AppColors.s2,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r20,
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.violetDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.pencilSimpleLine,
                      size: 20,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Leave editor?',
                      style: AppTypography.title().copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Changes on each section save when you tap Continue. '
                'You can sync everything now or discard edits made this session.',
                style: AppTypography.body(color: AppColors.textSecondary)
                    .copyWith(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 22),
              VcButton(
                label: 'Save & close',
                expanded: true,
                onTap: () =>
                    Navigator.of(context).pop(_ProfileEditCloseChoice.save),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_ProfileEditCloseChoice.discard),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: AppColors.coral,
                  backgroundColor: AppColors.coralDim,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.r12),
                ),
                child: Text(
                  'Discard changes',
                  style: AppTypography.button(color: AppColors.coral),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_ProfileEditCloseChoice.keepEditing),
                child: Text(
                  'Keep editing',
                  style: AppTypography.body(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || choice == null) return;

    switch (choice) {
      case _ProfileEditCloseChoice.keepEditing:
        return;
      case _ProfileEditCloseChoice.discard:
        await ProfileEditFinish.discardAndClose(context: context, ref: ref);
      case _ProfileEditCloseChoice.save:
        await ProfileEditFinish.saveAndClose(
          context: context,
          ref: ref,
          user: user,
        );
    }
  }
}
