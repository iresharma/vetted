import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_finalizer.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';

/// Persists in-memory edits and closes the edit flow.
abstract final class ProfileEditFinish {
  static Future<void> discardAndClose({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    await ref.read(profileDraftProvider.notifier).reload(mergeWithLocal: false);
    for (final sectionId in ProfileFlowResume.sectionOrder) {
      ref.invalidate(profileSectionProvider(sectionId));
    }
    if (context.mounted) Navigator.of(context).pop(false);
  }

  static Future<bool> saveAndClose({
    required BuildContext context,
    required WidgetRef ref,
    required User user,
  }) async {
    final syncOk = await ProfileFlowFinalizer.flushToBackend(ref);
    await ref.read(profileDraftProvider.notifier).reload(mergeWithLocal: false);
    await ref.read(registrationStatusProvider.notifier).refresh(user.uid);

    if (!context.mounted) return syncOk;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(syncOk);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.s2,
        behavior: SnackBarBehavior.floating,
        content: Text(
          syncOk
              ? 'Profile updated.'
              : 'Saved on this device — sync when you\'re back online.',
          style: AppTypography.body(
            color: syncOk ? AppColors.mint : AppColors.textSecondary,
          ),
        ),
      ),
    );
    return syncOk;
  }
}
