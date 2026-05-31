import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcNavTab { home, discover, matches, profile }

class VcBottomNav extends StatelessWidget {
  const VcBottomNav({
    super.key,
    required this.current,
    required this.onChanged,
    this.hasMatchNotification = false,
  });

  final VcNavTab current;
  final ValueChanged<VcNavTab> onChanged;
  final bool hasMatchNotification;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.s1,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight - 16,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                active: current == VcNavTab.home,
                onTap: () => onChanged(VcNavTab.home),
              ),
              _NavItem(
                icon: Icons.diamond_outlined,
                active: current == VcNavTab.discover,
                onTap: () => onChanged(VcNavTab.discover),
              ),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                active: current == VcNavTab.matches,
                onTap: () => onChanged(VcNavTab.matches),
                showNotification: hasMatchNotification,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                active: current == VcNavTab.profile,
                onTap: () => onChanged(VcNavTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
    this.showNotification = false,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.violet : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                if (showNotification)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (active)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.violet,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
