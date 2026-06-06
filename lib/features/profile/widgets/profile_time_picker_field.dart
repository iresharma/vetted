import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Tappable time selector that stores values as `HH:mm` (24-hour).
class ProfileTimePickerField extends StatelessWidget {
  const ProfileTimePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.accent = AccentColor.violet,
    this.placeholder = 'Select time',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final AccentColor accent;
  final String placeholder;

  static TimeOfDay? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String toStorage(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static bool get _useCupertinoPicker {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final initial = parse(value) ?? const TimeOfDay(hour: 12, minute: 0);
    final picked = _useCupertinoPicker
        ? await _showCupertinoTimePicker(context, initial)
        : await _showMaterialTimePicker(context, initial);
    if (picked != null) {
      onChanged(toStorage(picked));
    }
  }

  Future<TimeOfDay?> _showMaterialTimePicker(
    BuildContext context,
    TimeOfDay initial,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: accent.main,
                  onPrimary: AppColors.onViolet,
                  surface: AppColors.s2,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context,
    TimeOfDay initial,
  ) {
    var selected = initial;

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.s2,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    color: AppColors.s2,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: AppTypography.body(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Birth time',
                            textAlign: TextAlign.center,
                            style: AppTypography.body().copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(selected),
                          child: Text(
                            'Done',
                            style: AppTypography.body(color: accent.main)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 0.5, color: AppColors.border),
                  ClipRect(
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        brightness: Brightness.dark,
                        scaffoldBackgroundColor: AppColors.s2,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: 216,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: DateTime(
                            2000,
                            1,
                            1,
                            initial.hour,
                            initial.minute,
                          ),
                          backgroundColor: AppColors.s2,
                          onDateTimeChanged: (dateTime) {
                            selected = TimeOfDay(
                              hour: dateTime.hour,
                              minute: dateTime.minute,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = parse(value);
    final hasValue = time != null;
    final display = hasValue ? time.format(context) : placeholder;
    final textColor = hasValue ? AppColors.textPrimary : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickTime(context),
        borderRadius: AppRadius.r12,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.s2,
            borderRadius: AppRadius.r12,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.clock,
                  size: 18,
                  color: hasValue ? accent.main : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display,
                    style: AppTypography.body(color: textColor).copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
                if (hasValue)
                  GestureDetector(
                    onTap: () => onChanged(''),
                    child: Icon(
                      PhosphorIconsRegular.x,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  )
                else
                  Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
