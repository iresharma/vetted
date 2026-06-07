import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_option_row.dart';

class ValuesQuizStepDealbreakers extends StatefulWidget {
  const ValuesQuizStepDealbreakers({
    super.key,
    required this.answers,
    required this.onChanged,
  });

  final ValuesQuizAnswers answers;
  final ValueChanged<ValuesQuizAnswers> onChanged;

  @override
  State<ValuesQuizStepDealbreakers> createState() =>
      _ValuesQuizStepDealbreakersState();
}

class _ValuesQuizStepDealbreakersState extends State<ValuesQuizStepDealbreakers> {
  String? _expandedId;

  static const _fieldIcons = {
    'diet': PhosphorIconsRegular.forkKnife,
    'drinking': PhosphorIconsRegular.wine,
    'smoking': PhosphorIconsRegular.prohibit,
    'faith': PhosphorIconsRegular.handsPraying,
    'marriage_timeline': PhosphorIconsRegular.calendarHeart,
    'wants_children': PhosphorIconsRegular.baby,
    'family_structure': PhosphorIconsRegular.house,
    'open_to_inter_faith': PhosphorIconsRegular.heart,
  };

  void _setStrict(String fieldId, List<String> options, bool strict) {
    final selected = Set<String>.from(widget.answers.dealbreakerSelected);
    final acceptable =
        Map<String, List<String>>.from(widget.answers.dealbreakerAcceptable);

    if (strict) {
      selected.add(fieldId);
      acceptable[fieldId] = List<String>.from(options);
      _expandedId = fieldId;
    } else {
      selected.remove(fieldId);
      acceptable.remove(fieldId);
      if (_expandedId == fieldId) _expandedId = null;
    }

    widget.onChanged(widget.answers.copyWith(
      dealbreakerSelected: selected,
      dealbreakerAcceptable: acceptable,
    ));
    setState(() {});
  }

  void _toggleOption(String fieldId, String option, List<String> allOptions) {
    final current = List<String>.from(
      widget.answers.dealbreakerAcceptable[fieldId] ?? allOptions,
    );
    if (current.contains(option)) {
      if (current.length > 1) current.remove(option);
    } else {
      current.add(option);
    }
    final acceptable =
        Map<String, List<String>>.from(widget.answers.dealbreakerAcceptable);
    acceptable[fieldId] = current;
    widget.onChanged(widget.answers.copyWith(dealbreakerAcceptable: acceptable));
  }

  bool _useOptionRows(List<String> options) =>
      options.any((o) => o.length > 18) || options.length > 4;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);
    final active = widget.answers.dealbreakerSelected.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (active == 0)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 10 : 12),
            child: Text(
              'Nothing selected? That\'s fine — tap Continue.',
              style: AppTypography.supporting(color: AppColors.textSecondary),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 10 : 12),
            child: Text(
              '$active hard filter${active == 1 ? '' : 's'} set',
              style: AppTypography.chip(color: AppColors.violet),
            ),
          ),
        for (final field in valuesDealbreakerFields)
          _DealbreakerRow(
            label: field.label,
            icon: _fieldIcons[field.id] ?? PhosphorIconsRegular.seal,
            strict: widget.answers.dealbreakerSelected.contains(field.id),
            compact: compact,
            onToggleStrict: (strict) => _setStrict(field.id, field.options, strict),
            child: _expandedId == field.id &&
                    widget.answers.dealbreakerSelected.contains(field.id)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Which are okay?',
                        style: AppTypography.labelCaps(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      if (_useOptionRows(field.options))
                        for (final option in field.options)
                          ValuesQuizOptionRow(
                            label: option,
                            selected: (widget.answers.dealbreakerAcceptable[field.id] ??
                                    [])
                                .contains(option),
                            onTap: () =>
                                _toggleOption(field.id, option, field.options),
                          )
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final option in field.options)
                              GestureDetector(
                                onTap: () =>
                                    _toggleOption(field.id, option, field.options),
                                child: VcChip(
                                  label: option,
                                  variant: (widget.answers
                                              .dealbreakerAcceptable[field.id] ??
                                          [])
                                      .contains(option)
                                      ? VcChipVariant.violet
                                      : VcChipVariant.muted,
                                ),
                              ),
                          ],
                        ),
                    ],
                  )
                : null,
          ),
      ],
    );
  }
}

class _DealbreakerRow extends StatelessWidget {
  const _DealbreakerRow({
    required this.label,
    required this.icon,
    required this.strict,
    required this.compact,
    required this.onToggleStrict,
    required this.child,
  });

  final String label;
  final IconData icon;
  final bool strict;
  final bool compact;
  final ValueChanged<bool> onToggleStrict;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6 : 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(compact ? 10 : 12),
        decoration: BoxDecoration(
          color: strict ? AppColors.s3 : AppColors.s2,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: strict ? AppColors.violet : AppColors.border,
            width: strict ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: strict ? AppColors.violet : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.supporting(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _FlexibleToggle(strict: strict, onChanged: onToggleStrict),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _FlexibleToggle extends StatelessWidget {
  const _FlexibleToggle({required this.strict, required this.onChanged});

  final bool strict;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Flexible',
              selected: !strict,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Must match',
              selected: strict,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.chip(
            color: selected ? AppColors.onViolet : AppColors.textSecondary,
          ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
