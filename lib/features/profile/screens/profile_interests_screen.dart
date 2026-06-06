import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/data/interest_categories.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_micro_step_controller.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_section_hydration.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_mbti_section.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_option_widgets.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_loading_scaffold.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_vibe_preview.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileInterestsScreen extends ConsumerStatefulWidget {
  const ProfileInterestsScreen({super.key});

  @override
  ConsumerState<ProfileInterestsScreen> createState() =>
      _ProfileInterestsScreenState();
}

class _ProfileInterestsScreenState extends ConsumerState<ProfileInterestsScreen> {
  static const sectionId = 'interests';

  final _microStepController = ProfileMicroStepController();
  String? _openCategoryId;

  int _derivedMicroStep(
    Map<String, dynamic> values,
    ProfileField? interestsField,
  ) {
    return ProfileInterestsMicroResume.microStepIndex(
      values: values,
      minInterests: interestsField?.minCount ?? 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionState = ref.watch(profileSectionProvider(sectionId));
    final ready = ProfileSectionHydration.isReady(
      ref: ref,
      sectionId: sectionId,
      probeKeys: ProfileSectionProbeKeys.interests,
    );

    if (!ready) {
      return const ProfileSectionLoadingScaffold(stepIndex: 1);
    }

    final notifier = ref.read(profileSectionProvider(sectionId).notifier);
    final form = sectionState.formState;
    final values = form.values;

    final interestsField = _field(form, 'interests');
    final derivedStep = _derivedMicroStep(values, interestsField);
    final microStep = _microStepController.step(
      derived: derivedStep,
      min: 0,
      max: 2,
    );
    final interests = _asStringList(values['interests']);
    final weekendVibes = _asStringList(values['weekend_vibe']);
    final weekendField = _field(form, 'weekend_vibe');
    final maxInterests = interestsField?.maxSelections ?? 15;
    final maxWeekend = weekendField?.maxSelections ?? 3;

    final canAdvance = switch (microStep) {
      0 => interests.length >= (interestsField?.minCount ?? 3),
      1 => weekendVibes.isNotEmpty,
      _ => true,
    };

    final footerCaption = switch (microStep) {
      0 => interests.length < 3
          ? 'Pick at least 3 interests'
          : '${interests.length}/$maxInterests selected',
      1 => weekendVibes.isEmpty
          ? 'Pick at least one weekend vibe'
          : '${weekendVibes.length}/$maxWeekend selected',
      _ => 'Optional extras — skip anything you like',
    };

    return RegistrationScaffold(
      header: const ProfileStepHeader(stepIndex: 1),
      ctaLabel: microStep < 2 ? 'Next →' : 'Continue →',
      ctaEnabled: canAdvance && !sectionState.saving,
      ctaLoading: sectionState.saving,
      footerCaption: footerCaption,
      onCta: () => _onContinue(notifier, microStep),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _headlineFor(microStep),
            style: AppTypography.display().copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _subheadlineFor(microStep),
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          ProfileVibePreview(
            interests: interests,
            weekendVibes: weekendVibes,
            microStep: microStep,
            sectionProgress: sectionState.progress,
          ),
          const SizedBox(height: 16),
          _MicroStepIndicator(current: microStep),
          const SizedBox(height: 20),
          if (microStep == 0)
            _InterestsStep(
              openCategoryId: _openCategoryId,
              selected: interests,
              maxSelections: maxInterests,
              onCategoryTap: (id) => setState(
                () => _openCategoryId = _openCategoryId == id ? null : id,
              ),
              onToggleInterest: (label) {
                HapticFeedback.selectionClick();
                notifier.setValue(
                  'interests',
                  _toggleMulti(interests, label, maxInterests),
                );
              },
            )
          else if (microStep == 1)
            _RhythmStep(
              values: values,
              onWeekendChanged: (v) => notifier.setValue('weekend_vibe', v),
              onSingleChanged: notifier.setValue,
              weekendField: weekendField,
              travelField: _field(form, 'travel_frequency'),
              exerciseField: _field(form, 'exercise_frequency'),
            )
          else
            _NiceToKnowStep(
              values: values,
              onChanged: notifier.setValue,
              petField: _field(form, 'pet_preference'),
              socialField: _field(form, 'social_media_presence'),
              loveField: _field(form, 'love_language'),
            ),
          if (microStep > 0) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _microStepController.goBack(microStep));
              },
              child: Text(
                '← Back',
                style: AppTypography.supporting(color: AppColors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _headlineFor(int microStep) => switch (microStep) {
        0 => 'What lights\nyou up?',
        1 => 'Your\nrhythm.',
        _ => 'Nice to\nknow.',
      };

  String _subheadlineFor(int microStep) => switch (microStep) {
        0 => 'Tap a category, pick at least 3 things you genuinely enjoy.',
        1 => 'How you actually spend your time — be honest, not ideal.',
        _ => 'Optional extras that help people get the real you.',
      };

  Future<void> _onContinue(
    ProfileSectionNotifier notifier,
    int microStep,
  ) async {
    if (microStep < 2) {
      final ok = await notifier.save(requireValid: false);
      if (!ok || !mounted) return;
      HapticFeedback.mediumImpact();
      setState(_microStepController.clearOverride);
      return;
    }

    final ok = await notifier.save();
    if (!ok || !mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(profileFlowProvider.notifier).nextFrom(ProfileFlowStep.interests);
  }

  ProfileField? _field(ProfileFormState form, String id) {
    for (final f in form.visibleFields) {
      if (f.id == id) return f;
    }
    return null;
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  List<String> _toggleMulti(List<String> current, String item, int max) {
    final next = List<String>.from(current);
    if (next.contains(item)) {
      next.remove(item);
    } else if (next.length < max) {
      next.add(item);
    }
    return next;
  }
}

class _MicroStepIndicator extends StatelessWidget {
  const _MicroStepIndicator({required this.current});

  final int current;

  static const _labels = ['Into', 'Rhythm', 'Extra'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: active || done ? AppColors.mint : AppColors.s3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _labels[i],
                  style: AppTypography.supporting(
                    color: active ? AppColors.mint : AppColors.textMuted,
                  ).copyWith(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({
    required this.openCategoryId,
    required this.selected,
    required this.maxSelections,
    required this.onCategoryTap,
    required this.onToggleInterest,
  });

  final String? openCategoryId;
  final List<String> selected;
  final int maxSelections;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String> onToggleInterest;

  @override
  Widget build(BuildContext context) {
    final openCategory = openCategoryId != null
        ? InterestCategories.byId(openCategoryId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemCount: InterestCategories.all.length,
          itemBuilder: (context, index) {
            final cat = InterestCategories.all[index];
            final isOpen = openCategoryId == cat.id;
            final selectedInCat =
                cat.interests.where(selected.contains).length;
            final hasPicks = selectedInCat > 0;

            return GestureDetector(
              onTap: () => onCategoryTap(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isOpen
                      ? cat.color.withValues(alpha: 0.12)
                      : hasPicks
                          ? cat.color.withValues(alpha: 0.08)
                          : AppColors.s2,
                  borderRadius: AppRadius.r12,
                  border: Border.all(
                    color: isOpen || hasPicks ? cat.color : AppColors.border,
                    width: isOpen || hasPicks ? 1.5 : 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(cat.icon, size: 24, color: cat.color),
                        const Spacer(),
                        Text(
                          cat.label,
                          style: AppTypography.supporting().copyWith(
                            fontWeight: FontWeight.w600,
                            color: isOpen || hasPicks
                                ? cat.color
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (hasPicks)
                          Text(
                            selectedInCat == 1
                                ? '1 picked'
                                : '$selectedInCat picked',
                            style: AppTypography.supporting(color: cat.color)
                                .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                    if (hasPicks)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cat.color,
                            borderRadius: AppRadius.r20,
                          ),
                          child: Text(
                            '$selectedInCat',
                            style: AppTypography.supporting(color: Colors.white)
                                .copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Your picks', style: AppTypography.eyebrow(color: AppColors.mint)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in selected)
                ProfileIconChip(
                  label: interest,
                  icon: PhosphorIconsRegular.check,
                  selected: true,
                  accent: AccentColor.mint,
                  onTap: () => onToggleInterest(interest),
                ),
            ],
          ),
        ],
        if (openCategory != null) ...[
          const SizedBox(height: 16),
          Text(
            openCategory.label,
            style: AppTypography.eyebrow(color: openCategory.color),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in openCategory.interests)
                ProfileIconChip(
                  label: interest,
                  icon: PhosphorIconsRegular.star,
                  selected: selected.contains(interest),
                  accent: AccentColor.mint,
                  onTap: () => onToggleInterest(interest),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RhythmStep extends StatelessWidget {
  const _RhythmStep({
    required this.values,
    required this.onWeekendChanged,
    required this.onSingleChanged,
    required this.weekendField,
    required this.travelField,
    required this.exerciseField,
  });

  final Map<String, dynamic> values;
  final ValueChanged<List<String>> onWeekendChanged;
  final void Function(String fieldId, dynamic value) onSingleChanged;
  final ProfileField? weekendField;
  final ProfileField? travelField;
  final ProfileField? exerciseField;

  @override
  Widget build(BuildContext context) {
    final weekend = _list(values['weekend_vibe']);
    final maxWeekend = weekendField?.maxSelections ?? 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Weekend vibe', style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 88,
          ),
          itemCount: weekendField?.options.length ?? 0,
          itemBuilder: (context, index) {
            final option = weekendField!.options[index];
            final isSelected = weekend.contains(option);
            return _RhythmCard(
              label: option,
              icon: _weekendIcon(option),
              selected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onWeekendChanged(_toggle(weekend, option, maxWeekend));
              },
            );
          },
        ),
        if (travelField != null) ...[
          const SizedBox(height: 24),
          _SingleSelectRow(
            field: travelField!,
            value: values[travelField!.id]?.toString(),
            onChanged: (v) => onSingleChanged(travelField!.id, v),
          ),
        ],
        if (exerciseField != null) ...[
          const SizedBox(height: 20),
          _SingleSelectRow(
            field: exerciseField!,
            value: values[exerciseField!.id]?.toString(),
            onChanged: (v) => onSingleChanged(exerciseField!.id, v),
          ),
        ],
      ],
    );
  }

  static IconData _weekendIcon(String option) {
    if (option.startsWith('Homebody')) return PhosphorIconsRegular.house;
    if (option.startsWith('Social')) return PhosphorIconsRegular.usersThree;
    if (option.startsWith('Outdoors')) return PhosphorIconsRegular.tree;
    if (option.startsWith('Foodie')) return PhosphorIconsRegular.forkKnife;
    if (option.startsWith('Traveller')) return PhosphorIconsRegular.airplaneTilt;
    return PhosphorIconsRegular.shuffle;
  }

  List<String> _list(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : [];

  List<String> _toggle(List<String> current, String item, int max) {
    final next = List<String>.from(current);
    if (next.contains(item)) {
      next.remove(item);
    } else if (next.length < max) {
      next.add(item);
    }
    return next;
  }
}

class _RhythmCard extends StatelessWidget {
  const _RhythmCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final short = label.split('—').first.trim();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.mintDim : AppColors.s2,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: selected ? AppColors.mint : AppColors.border,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.mint : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                short,
                style: AppTypography.supporting(
                  color: selected ? AppColors.mint : AppColors.textSecondary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleSelectRow extends StatelessWidget {
  const _SingleSelectRow({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ProfileField field;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in field.options)
              ProfileIconChip(
                label: option,
                icon: PhosphorIconsRegular.circle,
                selected: option == value,
                accent: AccentColor.mint,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(option);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _NiceToKnowStep extends StatelessWidget {
  const _NiceToKnowStep({
    required this.values,
    required this.onChanged,
    required this.petField,
    required this.socialField,
    required this.loveField,
  });

  final Map<String, dynamic> values;
  final void Function(String fieldId, dynamic value) onChanged;
  final ProfileField? petField;
  final ProfileField? socialField;
  final ProfileField? loveField;

  @override
  Widget build(BuildContext context) {
    final loveSelected = values[loveField?.id ?? 'love_language'];
    final loveList = loveSelected is List
        ? loveSelected.map((e) => e.toString()).toList()
        : <String>[];
    final maxLove = loveField?.maxSelections ?? 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (petField != null)
          _SingleSelectRow(
            field: petField!,
            value: values[petField!.id]?.toString(),
            onChanged: (v) => onChanged(petField!.id, v),
          ),
        if (socialField != null) ...[
          const SizedBox(height: 20),
          _SingleSelectRow(
            field: socialField!,
            value: values[socialField!.id]?.toString(),
            onChanged: (v) => onChanged(socialField!.id, v),
          ),
        ],
        const SizedBox(height: 8),
        ProfileMbtiSection(
          selected: values['mbti']?.toString(),
          onChanged: (v) => onChanged('mbti', v),
        ),
        if (loveField != null) ...[
          const SizedBox(height: 16),
          Text(loveField!.label, style: AppTypography.eyebrow()),
          const SizedBox(height: 4),
          Text(
            'Optional · pick up to $maxLove',
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in loveField!.options)
                ProfileIconChip(
                  label: option,
                  icon: PhosphorIconsRegular.heart,
                  selected: loveList.contains(option),
                  accent: AccentColor.mint,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final next = List<String>.from(loveList);
                    if (next.contains(option)) {
                      next.remove(option);
                    } else if (next.length < maxLove) {
                      next.add(option);
                    }
                    onChanged(loveField!.id, next);
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}
