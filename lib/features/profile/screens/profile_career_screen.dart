import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/career_field_visuals.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_resume.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_micro_step_controller.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_section_hydration.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_form_state.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_career_preview.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_option_widgets.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_loading_scaffold.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileCareerScreen extends ConsumerStatefulWidget {
  const ProfileCareerScreen({super.key});

  @override
  ConsumerState<ProfileCareerScreen> createState() =>
      _ProfileCareerScreenState();
}

class _ProfileCareerScreenState extends ConsumerState<ProfileCareerScreen> {
  static const sectionId = 'career';

  final _microStepController = ProfileMicroStepController();
  late final TextEditingController _collegeController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _collegeController = TextEditingController();
    _jobTitleController = TextEditingController();
    _companyController = TextEditingController();
  }

  @override
  void dispose() {
    _collegeController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _syncTextControllers(Map<String, dynamic> values) {
    _syncController(_collegeController, values['college']?.toString() ?? '');
    _syncController(_jobTitleController, values['job_title']?.toString() ?? '');
    _syncController(_companyController, values['company']?.toString() ?? '');
  }

  void _syncController(TextEditingController controller, String next) {
    if (controller.text == next) return;
    controller.value = controller.value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  ProfileField? _field(ProfileFormState form, String id) {
    for (final f in form.visibleFields) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sectionState = ref.watch(profileSectionProvider(sectionId));
    final ready = ProfileSectionHydration.isReady(
      ref: ref,
      sectionId: sectionId,
      probeKeys: ProfileSectionProbeKeys.career,
    );

    if (!ready) {
      return const ProfileSectionLoadingScaffold(stepIndex: 2);
    }

    final notifier = ref.read(profileSectionProvider(sectionId).notifier);
    final form = sectionState.formState;
    final values = form.values;

    _syncTextControllers(values);

    final derivedStep = ProfileCareerMicroResume.microStepIndex(values: values);
    final microStep = _microStepController.step(
      derived: derivedStep,
      min: 0,
      max: 2,
    );

    final education = values['education_level']?.toString();
    final fieldOfWork = values['field_of_work']?.toString();
    final jobTitle = values['job_title']?.toString() ?? '';

    final canAdvance = switch (microStep) {
      0 => education != null && education.isNotEmpty,
      1 =>
        fieldOfWork != null &&
            fieldOfWork.isNotEmpty &&
            jobTitle.trim().isNotEmpty,
      _ => true,
    };

    final footerCaption = switch (microStep) {
      0 => education ?? 'Pick your highest education',
      1 => jobTitle.trim().isEmpty
          ? 'Add your role and industry'
          : '$jobTitle · ${fieldOfWork ?? '…'}',
      _ => 'Optional — add what you are comfortable sharing',
    };

    return RegistrationScaffold(
      header: const ProfileStepHeader(stepIndex: 2),
      ctaLabel: microStep < 2 ? 'Next →' : 'Continue →',
      ctaEnabled: canAdvance && !sectionState.saving,
      ctaLoading: sectionState.saving,
      footerCaption: footerCaption,
      onCta: () => _onContinue(notifier, microStep),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileCareerPreview(
            education: education,
            college: values['college']?.toString(),
            fieldOfWork: fieldOfWork,
            jobTitle: jobTitle,
            company: values['company']?.toString(),
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
            _EducationStep(
              field: _field(form, 'education_level'),
              selected: education,
              collegeController: _collegeController,
              onEducation: (v) => notifier.setValue('education_level', v),
              onCollege: (v) => notifier.setValue('college', v),
            )
          else if (microStep == 1)
            _WorkStep(
              industryField: _field(form, 'field_of_work'),
              selectedIndustry: fieldOfWork,
              jobTitleController: _jobTitleController,
              savedEducation: education,
              savedCollege: values['college']?.toString(),
              onIndustry: (v) => notifier.setValue('field_of_work', v),
              onJobTitle: (v) => notifier.setValue('job_title', v),
            )
          else
            _DetailsStep(
              values: values,
              companyController: _companyController,
              savedEducation: education,
              savedCollege: values['college']?.toString(),
              savedFieldOfWork: fieldOfWork,
              savedJobTitle: jobTitle,
              onChanged: notifier.setValue,
              employmentField: _field(form, 'employment_type'),
              workModeField: _field(form, 'work_mode'),
              incomeField: _field(form, 'income_bracket'),
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
    _flushTextFieldsToNotifier(notifier);
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
    ref.read(profileFlowProvider.notifier).nextFrom(ProfileFlowStep.career);
  }

  void _flushTextFieldsToNotifier(ProfileSectionNotifier notifier) {
    notifier.setValue('college', _collegeController.text.trim());
    notifier.setValue('job_title', _jobTitleController.text.trim());
    notifier.setValue('company', _companyController.text.trim());
  }
}

class _EducationStep extends StatelessWidget {
  const _EducationStep({
    required this.field,
    required this.selected,
    required this.collegeController,
    required this.onEducation,
    required this.onCollege,
  });

  final ProfileField? field;
  final String? selected;
  final TextEditingController collegeController;
  final ValueChanged<String> onEducation;
  final ValueChanged<String> onCollege;

  @override
  Widget build(BuildContext context) {
    final options = field?.options ?? [];

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
            childAspectRatio: 1.45,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onEducation(option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.amberDim : AppColors.s2,
                  borderRadius: AppRadius.r12,
                  border: Border.all(
                    color: isSelected ? AppColors.amber : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CareerFieldVisuals.educationIcon(option),
                      size: 22,
                      color: isSelected ? AppColors.amber : AppColors.textSecondary,
                    ),
                    const Spacer(),
                    Text(
                      option,
                      style: AppTypography.supporting(
                        color: isSelected ? AppColors.amber : AppColors.textSecondary,
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
        VcTextInput(
          placeholder: 'College or institution — optional',
          controller: collegeController,
          onChanged: onCollege,
        ),
      ],
    );
  }
}

class _WorkStep extends StatelessWidget {
  const _WorkStep({
    required this.industryField,
    required this.selectedIndustry,
    required this.jobTitleController,
    required this.savedEducation,
    required this.savedCollege,
    required this.onIndustry,
    required this.onJobTitle,
  });

  final ProfileField? industryField;
  final String? selectedIndustry;
  final TextEditingController jobTitleController;
  final String? savedEducation;
  final String? savedCollege;
  final ValueChanged<String> onIndustry;
  final ValueChanged<String> onJobTitle;

  @override
  Widget build(BuildContext context) {
    final options = industryField?.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedEducation != null && savedEducation!.isNotEmpty)
          _SavedCareerRow(
            labels: [
              savedEducation!,
              if (savedCollege != null && savedCollege!.isNotEmpty) savedCollege!,
            ],
            accent: AppColors.amber,
          ),
        if (selectedIndustry != null && selectedIndustry!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SavedCareerRow(
            labels: [selectedIndustry!],
            accent: AppColors.violet,
          ),
        ],
        if ((savedEducation?.isNotEmpty ?? false) ||
            (selectedIndustry?.isNotEmpty ?? false))
          const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option == selectedIndustry;
            final color = CareerFieldVisuals.industryColor(option);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onIndustry(option);
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
                      CareerFieldVisuals.industryIcon(option),
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
                        fontSize: 11,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        VcTextInput(
          placeholder: 'Your role — e.g. Software Engineer, Product Designer, CA',
          controller: jobTitleController,
          onChanged: onJobTitle,
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.values,
    required this.companyController,
    required this.savedEducation,
    required this.savedCollege,
    required this.savedFieldOfWork,
    required this.savedJobTitle,
    required this.onChanged,
    required this.employmentField,
    required this.workModeField,
    required this.incomeField,
  });

  final Map<String, dynamic> values;
  final TextEditingController companyController;
  final String? savedEducation;
  final String? savedCollege;
  final String? savedFieldOfWork;
  final String? savedJobTitle;
  final void Function(String fieldId, dynamic value) onChanged;
  final ProfileField? employmentField;
  final ProfileField? workModeField;
  final ProfileField? incomeField;

  @override
  Widget build(BuildContext context) {
    final savedLabels = <String>[
      if (savedEducation != null && savedEducation!.isNotEmpty) savedEducation!,
      if (savedCollege != null && savedCollege!.isNotEmpty) savedCollege!,
      if (savedFieldOfWork != null && savedFieldOfWork!.isNotEmpty)
        savedFieldOfWork!,
      if (savedJobTitle != null && savedJobTitle!.isNotEmpty) savedJobTitle!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedLabels.isNotEmpty)
          _SavedCareerRow(labels: savedLabels, accent: AppColors.amber),
        if (savedLabels.isNotEmpty) const SizedBox(height: 16),
        VcTextInput(
          placeholder: 'Company or organisation — optional',
          controller: companyController,
          onChanged: (v) => onChanged('company', v),
        ),
        if (employmentField != null) ...[
          const SizedBox(height: 20),
          _ChipRow(
            label: employmentField!.label,
            options: employmentField!.options,
            selected: values[employmentField!.id]?.toString(),
            onSelected: (v) => onChanged(employmentField!.id, v),
          ),
        ],
        if (workModeField != null) ...[
          const SizedBox(height: 20),
          _ChipRow(
            label: workModeField!.label,
            options: workModeField!.options,
            selected: values[workModeField!.id]?.toString(),
            onSelected: (v) => onChanged(workModeField!.id, v),
          ),
        ],
        if (incomeField != null) ...[
          const SizedBox(height: 20),
          _ChipRow(
            label: incomeField!.label,
            options: incomeField!.options,
            selected: values[incomeField!.id]?.toString(),
            onSelected: (v) => onChanged(incomeField!.id, v),
          ),
        ],
      ],
    );
  }
}

class _SavedCareerRow extends StatelessWidget {
  const _SavedCareerRow({required this.labels, required this.accent});

  final List<String> labels;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved so far', style: AppTypography.eyebrow(color: accent)),
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
                accent: AccentColor.amber,
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
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
                accent: AccentColor.amber,
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
