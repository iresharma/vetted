import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/data/cultural_field_visuals.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_finalizer.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_micro_step_controller.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_section_hydration.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/profile_edit_finish.dart';
import 'package:vetted_club_mobile/features/profile/profile_flow_mode.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_city_search_field.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_cultural_preview.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_renderer.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_option_widgets.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_hero.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_loading_scaffold.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_time_picker_field.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileCulturalScreen extends ConsumerStatefulWidget {
  const ProfileCulturalScreen({super.key});

  @override
  ConsumerState<ProfileCulturalScreen> createState() =>
      _ProfileCulturalScreenState();
}

class _ProfileCulturalScreenState extends ConsumerState<ProfileCulturalScreen> {
  static const sectionId = 'cultural';
  static const _accent = AccentColor.coral;

  final _microStepController = ProfileMicroStepController();

  bool _filled(String? value) => value != null && value.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final sectionState = ref.watch(profileSectionProvider(sectionId));
    final ready = ProfileSectionHydration.isReady(
      ref: ref,
      sectionId: sectionId,
      probeKeys: ProfileSectionProbeKeys.cultural,
    );

    if (!ready) {
      return const ProfileSectionLoadingScaffold(stepIndex: 3);
    }

    final notifier = ref.read(profileSectionProvider(sectionId).notifier);
    final form = sectionState.formState;
    final values = form.values;

    final derivedStep = ProfileCulturalMicroResume.microStepIndex(values: values);
    final microStep = _microStepController.step(
      derived: derivedStep,
      min: 0,
      max: 3,
    );

    final faith = values['faith']?.toString();
    final motherTongue = values['mother_tongue']?.toString();
    final familyStructure = values['family_structure']?.toString();
    final familyInvolvement = values['family_involvement']?.toString();
    final diet = values['diet']?.toString();
    final drinking = values['drinking']?.toString();
    final smoking = values['smoking']?.toString();
    final marriageTimeline = values['marriage_timeline']?.toString();
    final partnerApproach = values['partner_search_approach']?.toString();
    final wantsChildren = values['wants_children']?.toString();
    final willingToRelocate = values['willing_to_relocate']?.toString();

    final canAdvance = switch (microStep) {
      0 => _filled(faith) && _filled(motherTongue),
      1 => _filled(familyStructure) && _filled(familyInvolvement),
      2 => _filled(diet) && _filled(drinking) && _filled(smoking),
      _ =>
        _filled(marriageTimeline) &&
            _filled(partnerApproach) &&
            _filled(wantsChildren) &&
            _filled(willingToRelocate),
    };

    final footerCaption = switch (microStep) {
      0 => !_filled(faith)
          ? 'Pick your faith'
          : motherTongue ?? 'Pick your mother tongue',
      1 => familyStructure ?? 'Pick your family type',
      2 => diet ?? 'Pick diet, drinking, and smoking',
      _ => marriageTimeline ?? 'Set your timeline and intent',
    };

    final isEdit = ref.watch(profileFlowModeProvider) == ProfileFlowMode.edit;

    return RegistrationScaffold(
      header: const ProfileStepHeader(stepIndex: 3),
      ctaLabel: microStep < 3
          ? 'Next →'
          : (isEdit ? 'Save & close →' : 'Continue →'),
      ctaEnabled: canAdvance && !sectionState.saving,
      ctaLoading: sectionState.saving,
      footerCaption: footerCaption,
      onCta: () => _onContinue(notifier, microStep),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileCulturalPreview(
            faith: faith,
            motherTongue: motherTongue,
            familyStructure: familyStructure,
            familyInvolvement: familyInvolvement,
            diet: diet,
            marriageTimeline: marriageTimeline,
            microStep: microStep,
            sectionProgress: sectionState.progress,
          ),
          if (sectionState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              sectionState.error!,
              style: AppTypography.supporting(color: AppColors.coral),
            ),
          ],
          const SizedBox(height: 20),
          if (microStep == 0)
            _FaithStep(
              form: form,
              faith: faith,
              motherTongue: motherTongue,
              onChanged: notifier.setValue,
            )
          else if (microStep == 1)
            _FamilyStep(
              form: form,
              familyStructure: familyStructure,
              familyInvolvement: familyInvolvement,
              savedFaith: faith,
              savedMotherTongue: motherTongue,
              onChanged: notifier.setValue,
            )
          else if (microStep == 2)
            _LifeStep(
              form: form,
              diet: diet,
              drinking: drinking,
              smoking: smoking,
              savedFaith: faith,
              savedMotherTongue: motherTongue,
              savedFamilyStructure: familyStructure,
              savedFamilyInvolvement: familyInvolvement,
              onChanged: notifier.setValue,
            )
          else
            _FutureStep(
              form: form,
              values: values,
              savedFaith: faith,
              savedMotherTongue: motherTongue,
              savedFamilyStructure: familyStructure,
              savedDiet: diet,
              onChanged: notifier.setValue,
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

  Future<void> _onContinue(ProfileSectionNotifier notifier, int microStep) async {
    if (microStep < 3) {
      final ok = await notifier.save(requireValid: false);
      if (!ok || !mounted) return;
      HapticFeedback.mediumImpact();
      setState(_microStepController.clearOverride);
      return;
    }

    final ok = await notifier.save();
    if (!ok || !mounted) return;

    if (ref.read(profileFlowModeProvider) == ProfileFlowMode.edit) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !mounted) return;
      HapticFeedback.mediumImpact();
      await ProfileEditFinish.saveAndClose(
        context: context,
        ref: ref,
        user: user,
      );
      return;
    }

    await ProfileFlowFinalizer.flushToBackend(ref);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(profileFlowProvider.notifier).nextFrom(ProfileFlowStep.cultural);
  }

  static ProfileField? field(ProfileFormState form, String id) {
    for (final f in form.section.allFields) {
      if (f.id == id) return f;
    }
    return null;
  }
}

class _FaithStep extends StatelessWidget {
  const _FaithStep({
    required this.form,
    required this.faith,
    required this.motherTongue,
    required this.onChanged,
  });

  final ProfileFormState form;
  final String? faith;
  final String? motherTongue;
  final void Function(String fieldId, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    final faithField = _ProfileCulturalScreenState.field(form, 'faith');
    final tongueField = _ProfileCulturalScreenState.field(form, 'mother_tongue');
    final faithOptions = faithField?.options ?? [];
    final tongueOptions = tongueField?.options ?? [];

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
            childAspectRatio: 1.5,
          ),
          itemCount: faithOptions.length,
          itemBuilder: (context, index) {
            final option = faithOptions[index];
            final isSelected = option == faith;
            final color = CulturalFieldVisuals.faithColor(option);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged('faith', option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.12) : AppColors.s2,
                  borderRadius: AppRadius.r12,
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CulturalFieldVisuals.faithIcon(option),
                      size: 22,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                    const Spacer(),
                    Text(
                      option,
                      style: AppTypography.supporting(
                        color: isSelected ? color : AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text('Mother tongue', style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in tongueOptions)
              ProfileIconChip(
                label: option,
                icon: PhosphorIconsRegular.translate,
                selected: option == motherTongue,
                accent: _ProfileCulturalScreenState._accent,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged('mother_tongue', option);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        _OptionalDivider(),
        _OptionalFieldBlock(
          form: form,
          fieldIds: const [
            'religiosity',
            'languages_spoken',
            'community',
            'sub_caste',
            'open_to_inter_faith',
            'open_to_inter_community',
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FamilyStep extends StatelessWidget {
  const _FamilyStep({
    required this.form,
    required this.familyStructure,
    required this.familyInvolvement,
    required this.savedFaith,
    required this.savedMotherTongue,
    required this.onChanged,
  });

  final ProfileFormState form;
  final String? familyStructure;
  final String? familyInvolvement;
  final String? savedFaith;
  final String? savedMotherTongue;
  final void Function(String fieldId, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    final structureField =
        _ProfileCulturalScreenState.field(form, 'family_structure');
    final involvementField =
        _ProfileCulturalScreenState.field(form, 'family_involvement');
    final structureOptions = structureField?.options ?? [];
    final involvementOptions = involvementField?.options ?? [];
    final savedLabels = <String>[
      if (savedFaith != null && savedFaith!.isNotEmpty) savedFaith!,
      if (savedMotherTongue != null && savedMotherTongue!.isNotEmpty)
        savedMotherTongue!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedLabels.isNotEmpty) ...[
          _SavedCulturalRow(labels: savedLabels),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            for (final option in structureOptions)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: option != structureOptions.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onChanged('family_structure', option);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: option == familyStructure
                            ? AppColors.coralDim
                            : AppColors.s2,
                        borderRadius: AppRadius.r12,
                        border: Border.all(
                          color: option == familyStructure
                              ? AppColors.coral
                              : AppColors.border,
                          width: option == familyStructure ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CulturalFieldVisuals.familyStructureIcon(option),
                            size: 24,
                            color: option == familyStructure
                                ? AppColors.coral
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option,
                            textAlign: TextAlign.center,
                            style: AppTypography.supporting(
                              color: option == familyStructure
                                  ? AppColors.coral
                                  : AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Family involvement', style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        ProfileOptionCardList(
          options: involvementOptions,
          selected: familyInvolvement,
          accent: _ProfileCulturalScreenState._accent,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged('family_involvement', v);
          },
        ),
        const SizedBox(height: 16),
        _OptionalDivider(),
        _OptionalFieldBlock(
          form: form,
          fieldIds: const [
            'living_arrangement_post_marriage',
            'siblings',
            'family_location',
            'father_occupation',
            'mother_occupation',
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LifeStep extends StatelessWidget {
  const _LifeStep({
    required this.form,
    required this.diet,
    required this.drinking,
    required this.smoking,
    required this.savedFaith,
    required this.savedMotherTongue,
    required this.savedFamilyStructure,
    required this.savedFamilyInvolvement,
    required this.onChanged,
  });

  final ProfileFormState form;
  final String? diet;
  final String? drinking;
  final String? smoking;
  final String? savedFaith;
  final String? savedMotherTongue;
  final String? savedFamilyStructure;
  final String? savedFamilyInvolvement;
  final void Function(String fieldId, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    final dietField = _ProfileCulturalScreenState.field(form, 'diet');
    final drinkingField = _ProfileCulturalScreenState.field(form, 'drinking');
    final smokingField = _ProfileCulturalScreenState.field(form, 'smoking');
    final savedLabels = <String>[
      if (savedFaith != null && savedFaith!.isNotEmpty) savedFaith!,
      if (savedMotherTongue != null && savedMotherTongue!.isNotEmpty)
        savedMotherTongue!,
      if (savedFamilyStructure != null && savedFamilyStructure!.isNotEmpty)
        savedFamilyStructure!,
      if (savedFamilyInvolvement != null && savedFamilyInvolvement!.isNotEmpty)
        _shortInvolvement(savedFamilyInvolvement!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedLabels.isNotEmpty) ...[
          _SavedCulturalRow(labels: savedLabels),
          const SizedBox(height: 16),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
          ),
          itemCount: dietField?.options.length ?? 0,
          itemBuilder: (context, index) {
            final option = dietField!.options[index];
            final isSelected = option == diet;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged('diet', option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mintDim : AppColors.s2,
                  borderRadius: AppRadius.r12,
                  border: Border.all(
                    color: isSelected ? AppColors.mint : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CulturalFieldVisuals.dietIcon(option),
                      size: 22,
                      color: isSelected ? AppColors.mint : AppColors.textSecondary,
                    ),
                    const Spacer(),
                    Text(
                      option,
                      style: AppTypography.supporting(
                        color: isSelected ? AppColors.mint : AppColors.textSecondary,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        _HabitRow(
          label: 'Drinking',
          options: drinkingField?.options ?? [],
          selected: drinking,
          onSelected: (v) => onChanged('drinking', v),
        ),
        const SizedBox(height: 16),
        _HabitRow(
          label: 'Smoking',
          options: smokingField?.options ?? [],
          selected: smoking,
          onSelected: (v) => onChanged('smoking', v),
        ),
      ],
    );
  }

  static String _shortInvolvement(String value) {
    if (value.startsWith('Parents')) return 'Parents involved';
    if (value.startsWith('They know')) return 'Family knows';
    if (value.startsWith('This is private')) return 'Private for now';
    return value;
  }
}

class _FutureStep extends StatelessWidget {
  const _FutureStep({
    required this.form,
    required this.values,
    required this.savedFaith,
    required this.savedMotherTongue,
    required this.savedFamilyStructure,
    required this.savedDiet,
    required this.onChanged,
  });

  final ProfileFormState form;
  final Map<String, dynamic> values;
  final String? savedFaith;
  final String? savedMotherTongue;
  final String? savedFamilyStructure;
  final String? savedDiet;
  final void Function(String fieldId, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    final savedLabels = <String>[
      if (savedFaith != null && savedFaith!.isNotEmpty) savedFaith!,
      if (savedMotherTongue != null && savedMotherTongue!.isNotEmpty)
        savedMotherTongue!,
      if (savedFamilyStructure != null && savedFamilyStructure!.isNotEmpty)
        savedFamilyStructure!,
      if (savedDiet != null && savedDiet!.isNotEmpty) savedDiet!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedLabels.isNotEmpty) ...[
          _SavedCulturalRow(labels: savedLabels),
          const SizedBox(height: 16),
        ],
        _CoralSelectRow(
          label: 'Marriage timeline',
          field: _ProfileCulturalScreenState.field(form, 'marriage_timeline'),
          selected: values['marriage_timeline']?.toString(),
          onSelected: (v) => onChanged('marriage_timeline', v),
        ),
        const SizedBox(height: 20),
        Text('How do you want to approach this?', style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        ProfileOptionCardList(
          options: _ProfileCulturalScreenState.field(form, 'partner_search_approach')
                  ?.options ??
              [],
          selected: values['partner_search_approach']?.toString(),
          accent: _ProfileCulturalScreenState._accent,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            onChanged('partner_search_approach', v);
          },
        ),
        const SizedBox(height: 20),
        _CoralSelectRow(
          label: 'Children',
          field: _ProfileCulturalScreenState.field(form, 'wants_children'),
          selected: values['wants_children']?.toString(),
          onSelected: (v) => onChanged('wants_children', v),
        ),
        const SizedBox(height: 20),
        _CoralSelectRow(
          label: 'Relocate for marriage?',
          field: _ProfileCulturalScreenState.field(form, 'willing_to_relocate'),
          selected: values['willing_to_relocate']?.toString(),
          onSelected: (v) => onChanged('willing_to_relocate', v),
        ),
        const SizedBox(height: 24),
        _OptionalDivider(label: 'Horoscope & extras'),
        _HoroscopeExtrasBlock(
          form: form,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ProfileIconChip(
                label: option,
                icon: PhosphorIconsRegular.circle,
                selected: option == selected,
                accent: _ProfileCulturalScreenState._accent,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(option);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _CoralSelectRow extends StatelessWidget {
  const _CoralSelectRow({
    required this.label,
    required this.field,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final ProfileField? field;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = field?.options ?? [];
    final useCards = ProfileOptionCardList.useCardList(options);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.eyebrow()),
        const SizedBox(height: 10),
        if (useCards)
          ProfileOptionCardList(
            options: options,
            selected: selected,
            accent: _ProfileCulturalScreenState._accent,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onSelected(v);
            },
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ProfileIconChip(
                  label: option,
                  icon: PhosphorIconsRegular.circle,
                  selected: option == selected,
                  accent: _ProfileCulturalScreenState._accent,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelected(option);
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _OptionalDivider extends StatelessWidget {
  const _OptionalDivider({this.label = 'Optional — skip anything you like'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 0.5, color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: AppTypography.supporting(color: AppColors.textMuted),
              ),
            ),
            Expanded(child: Container(height: 0.5, color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HoroscopeExtrasBlock extends StatelessWidget {
  const _HoroscopeExtrasBlock({
    required this.form,
    required this.onChanged,
  });

  final ProfileFormState form;
  final void Function(String fieldId, dynamic value) onChanged;

  static const _fieldIds = [
    'horoscope_matters',
    'manglik_status',
    'rashi',
    'nakshatra',
    'gotra',
    'birth_time',
    'birth_place',
    'spouse_working_preference',
    'disability',
  ];

  @override
  Widget build(BuildContext context) {
    const accent = _ProfileCulturalScreenState._accent;

    return Column(
      children: [
        for (final id in _fieldIds)
          if (_visibleField(form, id) case final field?)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: switch (id) {
                'birth_time' => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileFieldLabel(
                        fieldId: field.id,
                        label: field.label,
                        accent: accent,
                      ),
                      const SizedBox(height: 10),
                      ProfileTimePickerField(
                        value: form.valueFor('birth_time')?.toString(),
                        accent: accent,
                        placeholder: 'Select birth time',
                        onChanged: (v) => onChanged('birth_time', v),
                      ),
                    ],
                  ),
                'birth_place' => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileFieldLabel(
                        fieldId: field.id,
                        label: field.label,
                        accent: accent,
                      ),
                      const SizedBox(height: 10),
                      ProfileCitySearchField(
                        value: form.valueFor('birth_place')?.toString(),
                        accent: accent,
                        placeholder: 'Search birth city in India',
                        helperText:
                            'City where you were born — for horoscope details',
                        onChanged: (v) => onChanged('birth_place', v),
                      ),
                    ],
                  ),
                _ => ProfileFieldRenderer(
                    field: field,
                    sectionId: _ProfileCulturalScreenState.sectionId,
                    value: form.valueFor(field.id),
                    onChanged: (v) => onChanged(field.id, v),
                  ),
              },
            ),
      ],
    );
  }

  ProfileField? _visibleField(ProfileFormState form, String id) {
    for (final f in form.section.allFields) {
      if (f.id == id && form.isVisible(f)) return f;
    }
    return null;
  }
}

class _OptionalFieldBlock extends StatelessWidget {
  const _OptionalFieldBlock({
    required this.form,
    required this.fieldIds,
    required this.onChanged,
  });

  final ProfileFormState form;
  final List<String> fieldIds;
  final void Function(String fieldId, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final id in fieldIds)
          if (_visibleField(form, id) case final field?)
            ProfileFieldRenderer(
              field: field,
              sectionId: _ProfileCulturalScreenState.sectionId,
              value: form.valueFor(field.id),
              onChanged: (v) => onChanged(field.id, v),
            ),
      ],
    );
  }

  ProfileField? _visibleField(ProfileFormState form, String id) {
    for (final f in form.section.allFields) {
      if (f.id == id && form.isVisible(f)) return f;
    }
    return null;
  }
}

class _SavedCulturalRow extends StatelessWidget {
  const _SavedCulturalRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved so far',
          style: AppTypography.eyebrow(color: AppColors.coral),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final label in labels)
              ProfileIconChip(
                label: label,
                icon: PhosphorIconsRegular.check,
                selected: true,
                accent: _ProfileCulturalScreenState._accent,
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}
