import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/auth/sign_out.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_finalizer.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_mode.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_career_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_complete_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_cultural_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_interests_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_intro_screen.dart';
import 'package:vetted_club_mobile/features/profile/screens/profile_you_and_photos_screen.dart';

/// Post-verification profile creation: intro → four biodata steps → complete.
class ProfileFlowScreen extends ConsumerStatefulWidget {
  const ProfileFlowScreen({
    super.key,
    required this.user,
    this.mode = ProfileFlowMode.onboarding,
    this.onProfileComplete,
  });

  final User user;
  final ProfileFlowMode mode;
  final VoidCallback? onProfileComplete;

  @override
  ConsumerState<ProfileFlowScreen> createState() => _ProfileFlowScreenState();
}

class _ProfileFlowScreenState extends ConsumerState<ProfileFlowScreen> {
  bool _signingOut = false;
  bool _resumeApplied = false;
  bool _resumeReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileSchemaProvider.future);
      ref.read(profileDraftProvider);
      _resumeFlowIfNeeded();
    });
  }

  Future<void> _resumeFlowIfNeeded() async {
    try {
      await ref.read(profileDraftProvider.future);
    } catch (_) {
      // Draft load failed — still show the flow from intro.
    }

    ProfileSchema? schema;
    try {
      schema = await ref.read(profileSchemaProvider.future);
    } catch (_) {
      // Schema load failed — fall back to intro.
    }

    // Warm section providers so draft values hydrate before we pick a step.
    for (final sectionId in ProfileFlowResume.sectionOrder) {
      ref.read(profileSectionProvider(sectionId));
    }

    await _waitForSectionHydration(schema);
    if (!mounted) return;

    if (schema != null) _applyResume(schema);
    if (mounted) setState(() => _resumeReady = true);
  }

  Future<void> _waitForSectionHydration(ProfileSchema? schema) async {
    if (schema == null) return;

    for (var attempt = 0; attempt < 30; attempt++) {
      if (!mounted) return;

      final draftAsync = ref.read(profileDraftProvider);
      if (draftAsync.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        continue;
      }

      var ready = true;
      for (final sectionId in ProfileFlowResume.sectionOrder) {
        final section = schema.sectionById(sectionId);
        if (section == null) continue;
        final state = ref.read(profileSectionProvider(sectionId));
        if (state.formState.section.allFields.isEmpty) {
          ready = false;
          break;
        }
      }

      if (ready) return;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  void _applyResume(ProfileSchema schema) {
    if (_resumeApplied) return;

    if (widget.mode == ProfileFlowMode.edit) {
      _resumeApplied = true;
      ref.read(profileFlowProvider.notifier).goTo(ProfileFlowStep.youAndPhotos);
      return;
    }

    final draftAsync = ref.read(profileDraftProvider);
    if (!draftAsync.hasValue && ProfileFlowFinalizer.mergedDraft(ref).values.isEmpty) {
      return;
    }

    final target = ProfileFlowResume.resumeTarget(
      draft: ProfileFlowFinalizer.mergedDraft(ref),
      schema: schema,
    );
    _resumeApplied = true;
    if (target == null) return;

    final step = switch (target) {
      'you_and_photos' => ProfileFlowStep.youAndPhotos,
      'interests' => ProfileFlowStep.interests,
      'career' => ProfileFlowStep.career,
      'cultural' => ProfileFlowStep.cultural,
      'complete' => ProfileFlowStep.complete,
      _ => ProfileFlowStep.intro,
    };
    if (step != ProfileFlowStep.intro) {
      Future.microtask(() {
        if (!mounted) return;
        ref.read(profileFlowProvider.notifier).goTo(step);
      });
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    final ok = await signOutUser(context);
    if (!ok && mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_resumeReady) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: VcLoadingIndicator(logoSize: 72),
        ),
      );
    }

    final step = ref.watch(profileFlowProvider);

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: AppMotion.slideDuration,
          switchInCurve: AppMotion.standardCurve,
          switchOutCurve: AppMotion.standardCurve,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: switch (step) {
            ProfileFlowStep.intro when widget.mode == ProfileFlowMode.onboarding =>
              ProfileIntroScreen(
                key: const ValueKey('profile_intro'),
                onContinue: () => ref
                    .read(profileFlowProvider.notifier)
                    .goTo(ProfileFlowStep.youAndPhotos),
              ),
            ProfileFlowStep.intro => const SizedBox.shrink(key: ValueKey('skip_intro')),
            ProfileFlowStep.youAndPhotos => const ProfileYouAndPhotosScreen(
                key: ValueKey('profile_you_and_photos'),
              ),
            ProfileFlowStep.interests => const ProfileInterestsScreen(
                key: ValueKey('profile_interests'),
              ),
            ProfileFlowStep.career => const ProfileCareerScreen(
                key: ValueKey('profile_career'),
              ),
            ProfileFlowStep.cultural => const ProfileCulturalScreen(
                key: ValueKey('profile_cultural'),
              ),
            ProfileFlowStep.complete when widget.mode == ProfileFlowMode.onboarding =>
              ProfileCompleteScreen(
                key: const ValueKey('profile_complete'),
                user: widget.user,
                onEnterClub: widget.onProfileComplete,
              ),
            ProfileFlowStep.complete => const SizedBox.shrink(
                key: ValueKey('skip_complete'),
              ),
          },
        ),
        if (widget.mode == ProfileFlowMode.onboarding && step != ProfileFlowStep.complete)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: TextButton(
                  onPressed: _signingOut ? null : _signOut,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _signingOut ? 'Signing out…' : 'Sign out',
                    style:
                        AppTypography.supporting(color: AppColors.textSecondary)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
