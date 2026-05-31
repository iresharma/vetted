import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Shared layout for registration steps: optional progress header, scroll body, CTA.
class RegistrationScaffold extends StatelessWidget {
  const RegistrationScaffold({
    super.key,
    this.header,
    required this.body,
    this.ctaLabel,
    this.onCta,
    this.ctaEnabled = true,
    this.ctaLoading = false,
    this.ctaIcon,
    this.ctaIconPosition = VcButtonIconPosition.trailing,
    this.ctaVariant = VcButtonVariant.violet,
    this.cta,
    this.footerCaption,
    this.scrollBody = true,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 28, 24, 16),
    this.footerPadding = const EdgeInsets.fromLTRB(24, 20, 24, 48),
  }) : assert(cta != null || ctaLabel != null);

  final Widget? header;
  final Widget body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool ctaEnabled;
  final bool ctaLoading;
  final IconData? ctaIcon;
  final VcButtonIconPosition ctaIconPosition;
  final VcButtonVariant ctaVariant;
  final Widget? cta;
  final String? footerCaption;
  final bool scrollBody;
  final EdgeInsets bodyPadding;
  final EdgeInsets footerPadding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final footerInsets = footerPadding.copyWith(
      bottom: footerPadding.bottom + bottomInset,
    );

    final bodyChild = Padding(padding: bodyPadding, child: body);

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header!,
            Expanded(
              child: scrollBody
                  ? SingleChildScrollView(child: bodyChild)
                  : Align(
                      alignment: Alignment.topCenter,
                      child: bodyChild,
                    ),
            ),
            Padding(
              padding: footerInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cta ??
                      VcButton(
                        label: ctaLabel!,
                        variant: ctaVariant,
                        size: VcButtonSize.large,
                        expanded: true,
                        enabled: ctaEnabled && !ctaLoading,
                        icon: ctaLoading ? null : ctaIcon,
                        iconPosition: ctaIconPosition,
                        onTap: ctaEnabled && !ctaLoading ? onCta : null,
                      ),
                  if (footerCaption != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      footerCaption!,
                      textAlign: TextAlign.center,
                      style: AppTypography.microLabel(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
