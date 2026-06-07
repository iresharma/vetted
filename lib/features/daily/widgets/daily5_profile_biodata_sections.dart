import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_hero.dart';

class Daily5ProfileBiodataSections extends StatelessWidget {
  const Daily5ProfileBiodataSections({super.key, required this.profile});

  final DailyProfileSummary profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_locationTags.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'Location',
            accent: AccentColor.violet,
            icon: PhosphorIconsRegular.mapPin,
            summaryLine: _locationSummary,
            tags: _locationTags,
          ),
        if (_careerTags.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'Career',
            accent: AccentColor.amber,
            icon: PhosphorIconsRegular.briefcase,
            summaryLine: _careerSummary,
            tags: _careerTags,
          ),
        if (_rootsTags.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'Faith & roots',
            accent: AccentColor.coral,
            icon: PhosphorIconsRegular.handsPraying,
            summaryLine: _rootsSummary,
            tags: _rootsTags,
          ),
        if (_familyTags.isNotEmpty || _familyRows.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'Family',
            accent: AccentColor.coral,
            icon: PhosphorIconsRegular.usersThree,
            summaryLine: _familySummary,
            tags: _familyTags,
            rows: _familyRows,
          ),
        if (_lifestyleTags.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'How they live',
            accent: AccentColor.mint,
            icon: PhosphorIconsRegular.forkKnife,
            summaryLine: _lifestyleSummary,
            tags: _lifestyleTags,
          ),
        if (_futureTags.isNotEmpty || _futureRows.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'What they want',
            accent: AccentColor.violet,
            icon: PhosphorIconsRegular.heart,
            summaryLine: _futureSummary,
            tags: _futureTags,
            rows: _futureRows,
          ),
        if (_vibeTags.isNotEmpty)
          Daily5BiodataSubsection(
            title: 'Vibe',
            accent: AccentColor.mint,
            icon: PhosphorIconsRegular.sparkle,
            summaryLine: _vibeSummary,
            tags: _vibeTags,
          ),
      ],
    );
  }

  String? _text(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  String? _formatted(String? value) {
    final text = _text(value);
    if (text == null) return null;
    final formatted = formatDailyProfileValue(text);
    return formatted == '—' ? null : formatted;
  }

  List<Daily5PreviewTag> _tagsFrom(
    List<({String? value, Color color})> items,
  ) {
    return items
        .map((item) {
          final label = _formatted(item.value);
          if (label == null) return null;
          return Daily5PreviewTag(label: label, color: item.color);
        })
        .whereType<Daily5PreviewTag>()
        .toList();
  }

  List<Daily5PreviewTag> get _locationTags => _tagsFrom([
        (value: profile.city, color: AppColors.violet),
        (value: profile.homeState, color: AppColors.violet),
      ]);

  String? get _locationSummary {
    final city = _formatted(profile.city);
    final state = _formatted(profile.homeState);
    if (city != null && state != null) return '$city · $state';
    return city ?? state;
  }

  List<Daily5PreviewTag> get _careerTags => _tagsFrom([
        (value: profile.educationLevel, color: AppColors.amber),
        (value: profile.fieldOfWork, color: AppColors.violet),
        (value: profile.profession, color: AppColors.mint),
        (value: profile.workMode, color: AppColors.amber),
      ]);

  String? get _careerSummary {
    final title = _formatted(profile.profession);
    final field = _formatted(profile.fieldOfWork);
    if (title != null && field != null) return '$title · $field';
    return title ?? field ?? _formatted(profile.educationLevel);
  }

  List<Daily5PreviewTag> get _rootsTags => _tagsFrom([
        (value: profile.faith, color: AppColors.coral),
        (value: profile.motherTongue, color: AppColors.violet),
      ]);

  String? get _rootsSummary {
    final faith = _formatted(profile.faith);
    final tongue = _text(profile.motherTongue);
    if (faith != null && tongue != null) return '$faith · speaks $tongue';
    return faith ?? tongue;
  }

  List<Daily5PreviewTag> get _familyTags => _tagsFrom([
        (value: profile.familyStructure, color: AppColors.amber),
      ]);

  List<Daily5ReadOnlyRow> get _familyRows {
    final involvement = _formatted(profile.familyInvolvement);
    if (involvement == null) return const [];
    return [
      Daily5ReadOnlyRow(
        fieldId: 'family_involvement',
        label: 'Family involvement',
        value: involvement,
        accent: AccentColor.coral,
      ),
    ];
  }

  String? get _familySummary {
    final structure = _formatted(profile.familyStructure);
    final involvement = _formatted(profile.familyInvolvement);
    if (structure != null && involvement != null) {
      return '$structure · $involvement';
    }
    return structure ?? involvement;
  }

  List<Daily5PreviewTag> get _lifestyleTags => _tagsFrom([
        (value: profile.diet, color: AppColors.mint),
        (value: profile.drinking, color: AppColors.amber),
        (value: profile.smoking, color: AppColors.coral),
      ]);

  String? get _lifestyleSummary {
    final diet = _formatted(profile.diet);
    if (diet != null) return diet;
    return _formatted(profile.drinking);
  }

  List<Daily5PreviewTag> get _futureTags => _tagsFrom([
        (value: profile.marriageTimeline, color: AppColors.coral),
        (value: profile.kidsPreference, color: AppColors.violet),
      ]);

  List<Daily5ReadOnlyRow> get _futureRows {
    final rows = <Daily5ReadOnlyRow>[];
    final relocate = profile.willingToRelocate;
    if (relocate != null) {
      rows.add(
        Daily5ReadOnlyRow(
          fieldId: 'willing_to_relocate',
          label: 'Open to relocate',
          value: relocate ? 'Yes' : 'No',
          accent: AccentColor.violet,
          valueColor: relocate ? AppColors.mint : AppColors.coral,
        ),
      );
    }
    final interFaith = profile.openToInterFaith;
    if (interFaith != null) {
      rows.add(
        Daily5ReadOnlyRow(
          fieldId: 'open_to_inter_faith',
          label: 'Inter-faith',
          value: interFaith ? 'Open' : 'Prefer same faith',
          accent: AccentColor.coral,
          valueColor: interFaith ? AppColors.mint : null,
        ),
      );
    }
    final approach = profile.profileExtras['partner_search_approach']?.toString();
    if (approach != null && approach.trim().isNotEmpty) {
      rows.add(
        Daily5ReadOnlyRow(
          fieldId: 'partner_search_approach',
          label: 'Dating approach',
          value: approach.trim(),
          accent: AccentColor.violet,
        ),
      );
    }
    return rows;
  }

  String? get _futureSummary {
    final timeline = _formatted(profile.marriageTimeline);
    if (timeline != null) return 'Looking to marry ${timeline.toLowerCase()}';
    return _formatted(profile.kidsPreference);
  }

  List<Daily5PreviewTag> get _vibeTags {
    final tags = <Daily5PreviewTag>[];
    final weekend = profile.profileExtras['weekend_vibe'];
    if (weekend is List) {
      for (final item in weekend.take(2)) {
        final label = _shortWeekend(item.toString());
        if (label.isNotEmpty) {
          tags.add(Daily5PreviewTag(label: label, color: AppColors.mint));
        }
      }
    }
    for (final interest in profile.interests.take(4)) {
      tags.add(Daily5PreviewTag(label: interest, color: AppColors.violet));
    }
    if (profile.interests.length > 4) {
      tags.add(
        Daily5PreviewTag(
          label: '+${profile.interests.length - 4}',
          color: AppColors.textSecondary,
        ),
      );
    }
    return tags;
  }

  String? get _vibeSummary {
    if (profile.interests.length >= 3) {
      return '${profile.interests.take(2).join(' · ')} & more';
    }
    if (profile.interests.isNotEmpty) {
      return profile.interests.join(' · ');
    }
    return null;
  }

  static String _shortWeekend(String full) {
    final dash = full.indexOf('—');
    if (dash > 0) return full.substring(0, dash).trim();
    return full.split(' ').first;
  }
}

class Daily5PreviewTag {
  const Daily5PreviewTag({required this.label, required this.color});

  final String label;
  final Color color;
}

class Daily5BiodataSubsection extends StatelessWidget {
  const Daily5BiodataSubsection({
    super.key,
    required this.title,
    required this.accent,
    required this.icon,
    this.summaryLine,
    this.tags = const [],
    this.rows = const [],
  });

  final String title;
  final AccentColor accent;
  final IconData icon;
  final String? summaryLine;
  final List<Daily5PreviewTag> tags;
  final List<Daily5ReadOnlyRow> rows;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty && rows.isEmpty && (summaryLine?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: VcSoftCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.dim,
                    borderRadius: AppRadius.r8,
                  ),
                  child: Icon(icon, size: 16, color: accent.main),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(title, style: AppTypography.labelCaps()),
                ),
              ],
            ),
            if (summaryLine != null && summaryLine!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm + 2),
              Text(
                summaryLine!,
                style: AppTypography.body().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in tags) _PreviewTagChip(tag: tag),
                ],
              ),
            ],
            if (rows.isNotEmpty) ...[
              if (tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(height: 0.5, color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),
              ],
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                rows[i],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class Daily5ReadOnlyRow extends StatelessWidget {
  const Daily5ReadOnlyRow({
    super.key,
    required this.fieldId,
    required this.label,
    required this.value,
    required this.accent,
    this.valueColor,
  });

  final String fieldId;
  final String label;
  final String value;
  final AccentColor accent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileFieldLabel(
          fieldId: fieldId,
          label: label,
          accent: accent,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body(
            color: valueColor ?? AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _PreviewTagChip extends StatelessWidget {
  const _PreviewTagChip({required this.tag});

  final Daily5PreviewTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.r20,
        border: Border.all(color: tag.color.withValues(alpha: 0.35)),
      ),
      child: Text(
        tag.label,
        style: AppTypography.supporting(color: tag.color).copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
