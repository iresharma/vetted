import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_visuals.dart';

/// Large tappable tile for single-select options (e.g. gender).
class ProfileOptionTile extends StatelessWidget {
  const ProfileOptionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = AccentColor.violet,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final AccentColor accent;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? accent.main : AppColors.border;
    final bg = selected ? accent.dim : AppColors.s2;
    final iconColor = selected ? accent.main : AppColors.textSecondary;
    final textColor = selected ? accent.main : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: borderColor,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.supporting(color: textColor).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width stacked cards for single-select fields with long option text.
class ProfileOptionCardList extends StatelessWidget {
  const ProfileOptionCardList({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.accent = AccentColor.violet,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  final AccentColor accent;

  static bool useCardList(List<String> options) {
    if (options.isEmpty) return false;
    return options.any((o) => o.length > 22) ||
        options.length <= 4 && options.every((o) => o.length > 14);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionCard(
              label: option,
              selected: option == selected,
              accent: accent,
              onTap: () => onChanged(option),
            ),
          ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AccentColor accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? accent.main : AppColors.border;
    final bg = selected ? accent.dim : AppColors.s2;
    final textColor = selected ? accent.main : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: borderColor,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? accent.main : AppColors.textMuted,
                    width: selected ? 5 : 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(color: textColor).copyWith(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact chip with leading icon — use only for short labels.
class ProfileIconChip extends StatelessWidget {
  const ProfileIconChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = AccentColor.violet,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final AccentColor accent;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? accent.main : AppColors.border;
    final bg = selected ? accent.dim : AppColors.s2;
    final contentColor = selected ? accent.main : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.r20,
          border: Border.all(color: borderColor, width: selected ? 1.5 : 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.supporting(color: contentColor).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2-column grid picker for gender-style fields.
class ProfileIconTileGrid extends StatelessWidget {
  const ProfileIconTileGrid({
    super.key,
    required this.fieldId,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.crossAxisCount = 2,
    this.accent = AccentColor.violet,
  });

  final String fieldId;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  final int crossAxisCount;
  final AccentColor accent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 96,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return ProfileOptionTile(
          label: option,
          icon: ProfileFieldVisuals.optionIcon(fieldId, option),
          selected: option == selected,
          accent: accent,
          onTap: () => onChanged(option),
        );
      },
    );
  }
}
