import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_renderer.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_hero.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_subsection_card.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileSectionScreen extends ConsumerWidget {
  const ProfileSectionScreen({
    super.key,
    required this.sectionId,
    required this.stepIndex,
    required this.headline,
    required this.subheadline,
  });

  final String sectionId;
  final int stepIndex;
  final String headline;
  final String subheadline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionState = ref.watch(profileSectionProvider(sectionId));
    final notifier = ref.read(profileSectionProvider(sectionId).notifier);
    final form = sectionState.formState;
    final section = form.section;

    final footer = sectionState.requiredRemaining == 0
        ? '${(sectionState.progress * 100).round()}% of this section done'
        : '${sectionState.requiredRemaining} required left';

    return RegistrationScaffold(
      header: ProfileStepHeader(stepIndex: stepIndex),
      ctaLabel: 'Continue →',
      ctaEnabled: sectionState.canContinue,
      ctaLoading: sectionState.saving,
      footerCaption: footer,
      onCta: () async {
        final ok = await notifier.save();
        if (!ok || !context.mounted) return;
        HapticFeedback.mediumImpact();
        ref.read(profileFlowProvider.notifier).nextFrom(
              switch (sectionId) {
                'you_and_photos' => ProfileFlowStep.youAndPhotos,
                'interests' => ProfileFlowStep.interests,
                'career' => ProfileFlowStep.career,
                'cultural' => ProfileFlowStep.cultural,
                _ => ProfileFlowStep.cultural,
              },
            );
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            headline,
            style: AppTypography.display().copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subheadline,
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          if (sectionState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              sectionState.error!,
              style: AppTypography.supporting(color: AppColors.coral),
            ),
          ],
          const SizedBox(height: 24),
          ProfileSectionHero(sectionId: sectionId),
          if (section.subsections.isNotEmpty)
            ...section.subsections.map((sub) {
              return ProfileSubsectionCard(
                subsection: sub,
                values: form.values,
                child: Column(
                  children: [
                    for (final field in sub.fields)
                      if (form.isVisible(field))
                        ProfileFieldRenderer(
                          field: field,
                          sectionId: sectionId,
                          value: form.valueFor(field.id),
                          onChanged: (v) => notifier.setValue(field.id, v),
                        ),
                  ],
                ),
              );
            })
          else
            ...[
              for (final field in form.visibleFields)
                ProfileFieldRenderer(
                  field: field,
                  sectionId: sectionId,
                  value: form.valueFor(field.id),
                  onChanged: (v) => notifier.setValue(field.id, v),
                ),
            ],
        ],
      ),
    );
  }
}
