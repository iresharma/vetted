import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/domain/trust_tier.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Borderless bento shortcuts — Daily 5 hero on top, Trust + Chats below.
class HomeShortcutsRow extends StatelessWidget {
  const HomeShortcutsRow({
    super.key,
    required this.onNavigate,
    this.trustScore,
    this.trustTier,
  });

  final ValueChanged<VcNavTab> onNavigate;
  final int? trustScore;
  final String? trustTier;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.r16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BentoCell(
            accent: AccentColor.violet,
            onTap: () => onNavigate(VcNavTab.daily5),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -4,
                  bottom: -12,
                  child: Icon(
                    PhosphorIconsFill.diamond,
                    size: 80,
                    color: AppColors.violet.withValues(alpha: 0.14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily 5',
                      style: AppTypography.labelCaps(color: AppColors.violet),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your morning picks',
                      style: AppTypography.title().copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Five curated profiles, refreshed daily',
                      style: AppTypography.supporting(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: _gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _BentoCell(
                  accent: AccentColor.mint,
                  onTap: () => onNavigate(VcNavTab.trust),
                  child: _CompactShortcutContent(
                    icon: PhosphorIconsRegular.shieldCheck,
                    accent: AccentColor.mint,
                    label: 'Trust',
                    value: trustScore != null
                        ? '$trustScore · ${TrustTierLabels.label(trustTier)}'
                        : 'Your score',
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _BentoCell(
                  accent: AccentColor.coral,
                  onTap: () => onNavigate(VcNavTab.chat),
                  child: _CompactShortcutContent(
                    icon: PhosphorIconsRegular.chatCircle,
                    accent: AccentColor.coral,
                    label: 'Chats',
                    value: 'Messages',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoCell extends StatelessWidget {
  const _BentoCell({
    required this.accent,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final AccentColor accent;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.dim,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.main.withValues(alpha: 0.08),
        highlightColor: accent.main.withValues(alpha: 0.04),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _CompactShortcutContent extends StatelessWidget {
  const _CompactShortcutContent({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final AccentColor accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: accent.main),
        const SizedBox(height: AppSpacing.md),
        Text(
          label,
          style: AppTypography.labelCaps(color: accent.main),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.supporting(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
