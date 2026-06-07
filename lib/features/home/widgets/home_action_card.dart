import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Trust-report-style navigational row card for the home tab.
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.label,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final String? label;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  static const _cardPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm + 2,
  );

  @override
  Widget build(BuildContext context) {
    final card = VcSoftCard(
      padding: _cardPadding,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: AppTypography.labelCaps(color: labelColor ?? iconColor),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(
                  title,
                  style: AppTypography.title().copyWith(fontSize: 14),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.supporting(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron && onTap != null)
            const Icon(
              PhosphorIconsRegular.caretRight,
              size: 16,
              color: AppColors.textMuted,
            ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.r16,
        child: card,
      ),
    );
  }
}
