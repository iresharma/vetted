import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';

/// Jump to any biodata section while editing.
class ProfileEditSectionSheet extends ConsumerWidget {
  const ProfileEditSectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.s1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ProfileEditSectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(profileFlowProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.s3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Jump to section', style: AppTypography.title().copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Changes save when you tap Continue on each section.',
              style: AppTypography.supporting(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            _SectionTile(
              icon: PhosphorIconsRegular.images,
              label: 'You & photos',
              selected: current == ProfileFlowStep.youAndPhotos,
              onTap: () => _go(context, ref, ProfileFlowStep.youAndPhotos),
            ),
            _SectionTile(
              icon: PhosphorIconsRegular.heart,
              label: 'Interests',
              selected: current == ProfileFlowStep.interests,
              onTap: () => _go(context, ref, ProfileFlowStep.interests),
            ),
            _SectionTile(
              icon: PhosphorIconsRegular.briefcase,
              label: 'Career',
              selected: current == ProfileFlowStep.career,
              onTap: () => _go(context, ref, ProfileFlowStep.career),
            ),
            _SectionTile(
              icon: PhosphorIconsRegular.handsPraying,
              label: 'Cultural & values',
              selected: current == ProfileFlowStep.cultural,
              onTap: () => _go(context, ref, ProfileFlowStep.cultural),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, WidgetRef ref, ProfileFlowStep step) {
    ref.read(profileFlowProvider.notifier).goTo(step);
    Navigator.of(context).pop();
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.r12,
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? AppColors.violetDim : AppColors.s2,
              borderRadius: AppRadius.r12,
              border: Border.all(
                color: selected ? AppColors.violet : AppColors.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? AppColors.violet : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body().copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      PhosphorIconsRegular.check,
                      size: 16,
                      color: AppColors.violet,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
