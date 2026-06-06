import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Read-only verified name and age from DigiLocker.
class VcVerifiedIdentityCard extends StatelessWidget {
  const VcVerifiedIdentityCard({
    super.key,
    required this.name,
    required this.age,
    this.loading = false,
  });

  final String? name;
  final int? age;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _VerifiedIdentitySkeleton();
    }

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

class _VerifiedIdentitySkeleton extends StatelessWidget {
  const _VerifiedIdentitySkeleton();

  @override
  Widget build(BuildContext context) {
    return VcSoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ShimmerBar(width: 110, height: 12),
              const Spacer(),
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ShimmerBar(width: 180, height: 16),
          const SizedBox(height: 10),
          _ShimmerBar(width: 48, height: 16),
          const SizedBox(height: 12),
          _ShimmerBar(width: 220, height: 10),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.s3,
        borderRadius: BorderRadius.circular(6),
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
