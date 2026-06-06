import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_steps.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_metrics.dart';

/// Conversational quiz shell — one question per screen, minimal chrome.
class ValuesQuizLayout extends StatelessWidget {
  const ValuesQuizLayout({
    super.key,
    required this.stepIndex,
    required this.body,
    required this.onCta,
    this.onBack,
    this.onSkip,
    this.ctaLabel = 'Continue',
    this.ctaEnabled = true,
    this.ctaLoading = false,
    this.showCta = true,
    this.embedded = true,
  });

  final int stepIndex;
  final Widget body;
  final VoidCallback? onCta;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final String ctaLabel;
  final bool ctaEnabled;
  final bool ctaLoading;
  final bool showCta;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final compact = ValuesQuizMetrics.compact(context);
    final hPad = ValuesQuizMetrics.horizontalPadding(context);
    final meta = valuesQuizStepMeta[stepIndex];
    final progress = (stepIndex + 1) / valuesQuizStepCount;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, compact ? 4 : 8, hPad, 0),
          child: Row(
            children: [
              _IconButton(
                icon: PhosphorIconsRegular.arrowLeft,
                onTap: ctaLoading ? null : onBack,
                visible: onBack != null,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.s3,
                    color: AppColors.violet,
                  ),
                ),
              ),
              _IconButton(
                icon: PhosphorIconsRegular.x,
                onTap: ctaLoading ? null : onSkip,
                visible: onSkip != null,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, compact ? 14 : 18, hPad, compact ? 10 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meta.headline,
                style: AppTypography.title().copyWith(
                  fontSize: compact ? 18 : 22,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                meta.hint,
                style: AppTypography.supporting(color: AppColors.textSecondary)
                    .copyWith(fontSize: compact ? 12 : 13, height: 1.35),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(stepIndex),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, compact ? 8 : 12),
            child: body,
          ),
        ),
        if (showCta)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, compact ? 12 : 16),
            child: VcButton(
              label: ctaLabel,
              variant: VcButtonVariant.violet,
              size: compact ? VcButtonSize.medium : VcButtonSize.large,
              expanded: true,
              enabled: ctaEnabled && !ctaLoading,
              onTap: ctaEnabled && !ctaLoading ? onCta : null,
            ),
          ),
      ],
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(bottom: false, child: content),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.visible,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 40, height: 40);

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: AppColors.textMuted),
      ),
    );
  }
}
