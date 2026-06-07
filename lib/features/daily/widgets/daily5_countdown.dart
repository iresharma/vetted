import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_drop_schedule.dart';

class Daily5Countdown extends StatefulWidget {
  const Daily5Countdown({
    super.key,
    this.title,
    this.subtitle = 'Five personalised profiles · 6 AM IST',
    this.onNavigate,
  });

  final String? title;
  final String subtitle;
  final ValueChanged<VcNavTab>? onNavigate;

  @override
  State<Daily5Countdown> createState() => _Daily5CountdownState();
}

class _Daily5CountdownState extends State<Daily5Countdown> {
  Timer? _timer;
  Duration _remaining = DailyDropSchedule.timeUntilNextDrop();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = DailyDropSchedule.timeUntilNextDrop());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.emptyMailbox,
                    height: 160,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      textAlign: TextAlign.center,
                      style: AppTypography.title().copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    DailyDropSchedule.formatCountdown(_remaining),
                    textAlign: TextAlign.center,
                    style: AppTypography.price(
                      fontSize: 44,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'until your next Daily 5',
                    textAlign: TextAlign.center,
                    style: AppTypography.supporting(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.supporting(color: AppColors.textSecondary),
                  ),
                  if (widget.onNavigate != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'While you wait',
                      style: AppTypography.eyebrow(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: VcButton(
                        label: 'See events near you',
                        variant: VcButtonVariant.violet,
                        size: VcButtonSize.medium,
                        expanded: true,
                        onTap: () => widget.onNavigate!(VcNavTab.home),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: VcButton.ghost(
                        label: 'Check messages',
                        size: VcButtonSize.medium,
                        expanded: true,
                        onTap: () => widget.onNavigate!(VcNavTab.chat),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
