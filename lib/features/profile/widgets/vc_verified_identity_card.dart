import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Read-only verified name and age from DigiLocker.
class VcVerifiedIdentityCard extends StatelessWidget {
  const VcVerifiedIdentityCard({
    super.key,
    required this.name,
    required this.age,
  });

  final String? name;
  final int? age;

  @override
  Widget build(BuildContext context) {
    final displayName = (name?.trim().isNotEmpty == true) ? name!.trim() : '—';
    final displayAge = age != null ? '$age' : '—';

    return VcSoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Verified identity',
                style: AppTypography.eyebrow(color: AppColors.mint),
              ),
              const Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LockedRow(label: 'Name', value: displayName),
          const SizedBox(height: 10),
          _LockedRow(label: 'Age', value: displayAge),
          const SizedBox(height: 12),
          Text(
            'Locked from DigiLocker · cannot be edited',
            style: AppTypography.supporting(color: AppColors.textMuted)
                .copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: AppTypography.supporting(color: AppColors.textSecondary)
                .copyWith(fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
