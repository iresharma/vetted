import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_mode.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_screen.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';

/// Opens the biodata editor from home with a fresh server draft.
abstract final class ProfileEditLauncher {
  static Future<bool?> open({
    required BuildContext context,
    required WidgetRef ref,
    required User user,
    ProfileFlowStep initialStep = ProfileFlowStep.youAndPhotos,
  }) async {
    await ref.read(profileDraftProvider.notifier).reload(mergeWithLocal: false);

    for (final sectionId in ProfileFlowResume.sectionOrder) {
      ref.invalidate(profileSectionProvider(sectionId));
    }

    ref.read(profileFlowProvider.notifier).reset();
    ref.read(profileFlowProvider.notifier).goTo(initialStep);
    ref.read(profileFlowModeProvider.notifier).set(ProfileFlowMode.edit);

    if (!context.mounted) return null;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfileFlowScreen(
          user: user,
          mode: ProfileFlowMode.edit,
        ),
      ),
    );

    ref.read(profileFlowModeProvider.notifier).set(ProfileFlowMode.onboarding);
    ref.read(profileFlowProvider.notifier).reset();

    return result;
  }
}
