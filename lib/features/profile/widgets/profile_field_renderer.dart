import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_city_search_field.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_time_picker_field.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_visuals.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_option_widgets.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_hero.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_photo_grid.dart';

class ProfileFieldRenderer extends StatelessWidget {
  const ProfileFieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.sectionId = 'you_and_photos',
    this.photoSlots,
    this.maxPhotos = 8,
    this.onPhotoAdd,
    this.onPhotoRemove,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;
  final List<ProfilePhotoSlot>? photoSlots;
  final int maxPhotos;
  final void Function(int index)? onPhotoAdd;
  final void Function(int index)? onPhotoRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: switch (field.type) {
        ProfileFieldType.text => _TextFieldWidget(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.number => _NumberFieldWidget(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.singleSelect => _SingleSelectField(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.citySearch => _CitySearchField(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.multiSelect => _MultiSelectField(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.prompt => _PromptField(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
        ProfileFieldType.photoUpload => _PhotoField(
            field: field,
            sectionId: sectionId,
            slots: photoSlots ?? const [],
            maxPhotos: maxPhotos,
            onAdd: onPhotoAdd,
            onRemove: onPhotoRemove,
          ),
        ProfileFieldType.time => _TimeField(
            field: field,
            value: value,
            onChanged: onChanged,
            sectionId: sectionId,
          ),
      },
    );
  }
}

class _TextFieldWidget extends StatefulWidget {
  const _TextFieldWidget({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  State<_TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<_TextFieldWidget> {
  late final TextEditingController _controller;

  String get _textValue => widget.value?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textValue);
  }

  @override
  void didUpdateWidget(_TextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_textValue);
  }

  void _syncController(String next) {
    if (next == _controller.text) return;
    _controller.value = _controller.value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = ProfileFieldVisuals.sectionAccent(widget.sectionId);
    return _LabeledFieldShell(
      fieldId: widget.field.id,
      label: widget.field.label,
      accent: accent,
      child: VcTextInput(
        placeholder: 'Enter ${widget.field.label.toLowerCase()}',
        controller: _controller,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _LabeledFieldShell extends StatelessWidget {
  const _LabeledFieldShell({
    required this.fieldId,
    required this.label,
    required this.child,
    this.accent = AccentColor.violet,
  });

  final String fieldId;
  final String label;
  final Widget child;
  final AccentColor accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileFieldLabel(fieldId: fieldId, label: label, accent: accent),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _NumberFieldWidget extends StatefulWidget {
  const _NumberFieldWidget({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  State<_NumberFieldWidget> createState() => _NumberFieldWidgetState();
}

class _NumberFieldWidgetState extends State<_NumberFieldWidget> {
  late final TextEditingController _controller;

  String get _textValue => widget.value?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _textValue);
  }

  @override
  void didUpdateWidget(_NumberFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_textValue);
  }

  void _syncController(String next) {
    if (next == _controller.text) return;
    _controller.value = _controller.value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LabeledFieldShell(
      fieldId: widget.field.id,
      label: widget.field.label,
      accent: ProfileFieldVisuals.sectionAccent(widget.sectionId),
      child: VcTextInput(
        placeholder: '${widget.field.min ?? 140}–${widget.field.max ?? 220} cm',
        keyboardType: TextInputType.number,
        controller: _controller,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _SingleSelectField extends StatelessWidget {
  const _SingleSelectField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);
    final selected = value?.toString();

    Widget picker;
    if (field.id == 'gender') {
      picker = ProfileIconTileGrid(
        fieldId: field.id,
        options: field.options,
        selected: selected,
        onChanged: onChanged,
        accent: accent,
      );
    } else if (ProfileOptionCardList.useCardList(field.options)) {
      picker = ProfileOptionCardList(
        options: field.options,
        selected: selected,
        onChanged: onChanged,
        accent: accent,
      );
    } else {
      picker = Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final option in field.options)
            ProfileIconChip(
              label: option,
              icon: ProfileFieldVisuals.optionIcon(field.id, option),
              selected: option == selected,
              accent: accent,
              onTap: () => onChanged(option),
            ),
        ],
      );
    }

    return _LabeledFieldShell(
      fieldId: field.id,
      label: field.label,
      accent: accent,
      child: picker,
    );
  }
}

class _CitySearchField extends StatelessWidget {
  const _CitySearchField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);
    final selected = value?.toString();
    final placeholder = switch (field.id) {
      'home_state' => 'Search hometown in India',
      'birth_place' => 'Search birth city in India',
      _ => 'Search city in India',
    };
    final helperText = switch (field.id) {
      'home_state' => 'Where you grew up — search any city in India',
      'birth_place' => 'City where you were born — for horoscope details',
      _ => 'Search from thousands of cities across India',
    };

    return _LabeledFieldShell(
      fieldId: field.id,
      label: field.label,
      accent: accent,
      child: ProfileCitySearchField(
        value: selected,
        accent: accent,
        placeholder: placeholder,
        helperText: helperText,
        onChanged: (city) => onChanged(city),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);

    return _LabeledFieldShell(
      fieldId: field.id,
      label: field.label,
      accent: accent,
      child: ProfileTimePickerField(
        value: value?.toString(),
        accent: accent,
        placeholder: 'Select birth time',
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  Widget build(BuildContext context) {
    final selected = value is List
        ? List<String>.from(value.map((e) => e.toString()))
        : <String>[];
    final max = field.maxSelections ?? field.options.length;
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileFieldLabel(
                fieldId: field.id,
                label: field.label,
                accent: accent,
              ),
            ),
            Text(
              '${selected.length}/$max',
              style: AppTypography.chip(color: AppColors.amber),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final option in field.options)
              ProfileIconChip(
                label: option,
                icon: ProfileFieldVisuals.optionIcon(field.id, option),
                selected: selected.contains(option),
                accent: accent,
                onTap: () {
                  final next = List<String>.from(selected);
                  if (next.contains(option)) {
                    next.remove(option);
                  } else if (next.length < max) {
                    next.add(option);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _PromptField extends StatefulWidget {
  const _PromptField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.sectionId,
  });

  final ProfileField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String sectionId;

  @override
  State<_PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends State<_PromptField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_PromptField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value?.toString() ?? '';
    if (next == _controller.text) return;
    _controller.value = _controller.value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.field.maxChars ?? 150;
    final accent = ProfileFieldVisuals.sectionAccent(widget.sectionId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.dim,
                borderRadius: AppRadius.r12,
              ),
              child: Icon(
                Icons.format_quote_rounded,
                size: 20,
                color: accent.main,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: VcTextInput.prompt(
                label: widget.field.promptText ?? widget.field.label,
                controller: _controller,
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_controller.text.length}/$max',
            style: AppTypography.supporting(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.field,
    required this.sectionId,
    required this.slots,
    required this.maxPhotos,
    this.onAdd,
    this.onRemove,
  });

  final ProfileField field;
  final String sectionId;
  final List<ProfilePhotoSlot> slots;
  final int maxPhotos;
  final void Function(int index)? onAdd;
  final void Function(int index)? onRemove;

  @override
  Widget build(BuildContext context) {
    final filled = slots.where((s) => s.isFilled).length;
    final min = field.minCount ?? 3;
    final accent = ProfileFieldVisuals.sectionAccent(sectionId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileFieldLabel(
                fieldId: field.id,
                label: field.label,
                accent: accent,
              ),
            ),
            Text(
              '$filled/$maxPhotos',
              style: AppTypography.chip(color: AppColors.violet),
            ),
          ],
        ),
        const SizedBox(height: 8),
        VcPhotoGrid(
          slots: slots,
          maxPhotos: maxPhotos,
          onAdd: onAdd ?? (_) {},
          onRemove: onRemove ?? (_) {},
        ),
        const SizedBox(height: 6),
        Text(
          'Add at least $min photos',
          style: AppTypography.supporting(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
