import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/registration/widgets/membership_plan_card.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_step_header.dart';

enum MembershipPlan { monthly, annual }

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  MembershipPlan _plan = MembershipPlan.annual;

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      header: const RegistrationStepHeader(stepIndex: 2),
      ctaLabel: 'Start membership →',
      onCta: widget.onContinue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stay in\nthe club.',
            style: AppTypography.display().copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Active membership keeps the pool serious. The moment someone stops looking, they leave.',
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),
          MembershipPlanCard(
            title: 'Monthly',
            price: '₹199',
            period: 'per month',
            selected: _plan == MembershipPlan.monthly,
            priceAccent: _plan == MembershipPlan.monthly,
            onTap: () => setState(() => _plan = MembershipPlan.monthly),
          ),
          const SizedBox(height: 12),
          MembershipPlanCard(
            title: 'Annual',
            price: '₹1,999',
            period: 'per year',
            badge: '2 months free',
            selected: _plan == MembershipPlan.annual,
            priceAccent: _plan == MembershipPlan.annual,
            onTap: () => setState(() => _plan = MembershipPlan.annual),
          ),
          const SizedBox(height: 20),
          Text(
            'Cancel anytime · No lock-in',
            textAlign: TextAlign.center,
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
