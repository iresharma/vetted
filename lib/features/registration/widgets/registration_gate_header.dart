import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

/// Two-gate progress (membership pass → identity) for registration steps.
class RegistrationGateHeader extends StatelessWidget {
  const RegistrationGateHeader({
    super.key,
    required this.currentGateIndex,
    this.totalGates = 2,
  });

  /// Zero-based; 1 = second gate (identity).
  final int currentGateIndex;
  final int totalGates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'GATE ${currentGateIndex + 1} OF $totalGates',
            style: AppTypography.eyebrow(color: AppColors.violet),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(totalGates, (index) {
              final color = _segmentColor(index, currentGateIndex);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _segmentColor(int index, int current) {
    if (index < current) return AppColors.mint;
    if (index == current) return AppColors.violet;
    return AppColors.s3;
  }
}

enum _MilestoneState { done, active, pending }

/// Horizontal pass + identity milestones (2 gates).
class RegistrationGateMilestones extends StatelessWidget {
  const RegistrationGateMilestones({
    super.key,
    required this.passLabel,
    required this.currentGateIndex,
    this.identityVerified = false,
  });

  final String passLabel;

  /// 0 = on pass screen, 1 = on identity screen.
  final int currentGateIndex;
  final bool identityVerified;

  @override
  Widget build(BuildContext context) {
    final passDone = identityVerified || currentGateIndex > 0;
    final identityDone = identityVerified;
    final identityActive = !identityVerified && currentGateIndex == 1;

    return Row(
      children: [
        Expanded(
          child: _MilestoneTile(
            state: passDone ? _MilestoneState.done : _MilestoneState.active,
            label: passLabel,
            icon: passDone ? Icons.check_rounded : Icons.credit_card_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MilestoneTile(
            state: identityDone
                ? _MilestoneState.done
                : identityActive
                    ? _MilestoneState.active
                    : _MilestoneState.pending,
            label: 'IDENTITY\nVERIFY',
            icon: identityDone
                ? Icons.check_rounded
                : Icons.verified_user_outlined,
          ),
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.state,
    required this.label,
    required this.icon,
  });

  final _MilestoneState state;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = switch (state) {
      _MilestoneState.done => AppColors.mint,
      _MilestoneState.active => AppColors.violet,
      _MilestoneState.pending => AppColors.textMuted,
    };

    final bg = switch (state) {
      _MilestoneState.done => AppColors.mintDim,
      _MilestoneState.active => AppColors.violetDim,
      _MilestoneState.pending => AppColors.s3,
    };

    final showBorder = state == _MilestoneState.active;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.r10,
            border: showBorder
                ? Border.all(color: AppColors.violet, width: 1.5)
                : Border.all(color: AppColors.border, width: 0.5),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: accent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelCaps(color: accent).copyWith(
            fontSize: 9,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
