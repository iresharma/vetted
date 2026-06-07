import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_profile_biodata_sections.dart';

class Daily5FullProfileSheet extends StatelessWidget {
  const Daily5FullProfileSheet({
    super.key,
    required this.profile,
    this.onPass,
    this.onSendInterest,
  });

  final DailyProfileSummary profile;
  final VoidCallback? onPass;
  final VoidCallback? onSendInterest;

  static Future<void> show(
    BuildContext context, {
    required DailyProfileSummary profile,
    VoidCallback? onPass,
    VoidCallback? onSendInterest,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Daily5FullProfileSheet(
        profile: profile,
        onPass: onPass == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                onPass();
              },
        onSendInterest: onSendInterest == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                onSendInterest();
              },
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[
      if (profile.city != null && profile.city!.isNotEmpty) profile.city!,
      if (profile.profession != null && profile.profession!.isNotEmpty)
        profile.profession!,
      if (profile.faith != null)
        profile.faith!.replaceAll('_', ' '),
    ];
    return parts.join(' · ');
  }

  String get _firstName {
    final clean =
        (profile.displayName ?? 'Member').replaceFirst(RegExp(r'^\[TEST\]\s*'), '');
    return clean.split(RegExp(r'[\s,]')).first;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final ageLabel = profile.age != null ? ', ${profile.age}' : '';

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                children: [
                  Text(
                    'FULL PROFILE',
                    style: AppTypography.microLabel(color: AppColors.textMuted),
                  ),
                  if (profile.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: profile.photoUrls.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: AppRadius.r16,
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: Image.network(
                                profile.photoUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${profile.displayName ?? 'Member'}$ageLabel',
                    style: AppTypography.title().copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  if (_subtitle.isNotEmpty)
                    Text(_subtitle, style: AppTypography.supporting()),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      VcTrustBadge.trustTier(profile.trustTier),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Trust score ${profile.trustScore}',
                        style: AppTypography.supporting(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (profile.prompts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Prompts',
                      style: AppTypography.eyebrow(color: AppColors.violet),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final prompt in profile.prompts) ...[
                      VcSoftCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prompt.question,
                              style: AppTypography.title().copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prompt.answer,
                              style: AppTypography.supporting(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Biodata',
                    style: AppTypography.eyebrow(color: AppColors.violet),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Daily5ProfileBiodataSections(profile: profile),
                ],
              ),
            ),
            if (onPass != null || onSendInterest != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    if (onPass != null)
                      Expanded(
                        child: VcButton.ghost(
                          label: 'Pass',
                          icon: PhosphorIconsRegular.x,
                          iconPosition: VcButtonIconPosition.leading,
                          onTap: onPass,
                        ),
                      ),
                    if (onPass != null && onSendInterest != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (onSendInterest != null)
                      Expanded(
                        flex: onPass != null ? 2 : 1,
                        child: VcButton.muted(
                          label: 'Send interest to $_firstName',
                          icon: PhosphorIconsRegular.heart,
                          iconPosition: VcButtonIconPosition.leading,
                          onTap: onSendInterest,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
