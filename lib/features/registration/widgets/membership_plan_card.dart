import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/neopop/neopop_pressable.dart';

class MembershipPlanCard extends StatelessWidget {
  const MembershipPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
    this.priceAccent = false,
  });

  final String title;
  final String price;
  final String period;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final bool priceAccent;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.violet : AppColors.border;
    final shadowColor = selected ? AppColors.violetDark : AppColors.s4;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.s2,
        borderRadius: AppRadius.r14,
        border: Border.all(color: borderColor, width: selected ? 1 : 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.body().copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amber,
                            borderRadius: AppRadius.r6,
                          ),
                          child: Text(
                            badge!,
                            style: AppTypography.chip(color: AppColors.onAmber)
                                .copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _PlanRadio(selected: selected),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: AppTypography.price(
                fontSize: 34,
                color: priceAccent ? AppColors.violet : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period,
              style: AppTypography.supporting(color: AppColors.textMuted)
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    if (!selected) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return NeoPopPressable(
      onTap: onTap,
      shadowColor: shadowColor,
      borderRadius: AppRadius.r14,
      idleShadowOffset: 4,
      child: card,
    );
  }
}

class _PlanRadio extends StatelessWidget {
  const _PlanRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.violet : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.violet,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
