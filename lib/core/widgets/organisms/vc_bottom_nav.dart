import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';

enum VcNavTab { home, chat, daily5, trust, profile }

class VcBottomNav extends StatelessWidget {
  const VcBottomNav({
    super.key,
    required this.current,
    required this.onChanged,
    this.hasChatNotification = false,
  });

  final VcNavTab current;
  final ValueChanged<VcNavTab> onChanged;
  final bool hasChatNotification;

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
                icon: Icons.chat_bubble_outline_rounded,
                active: current == VcNavTab.chat,
                onTap: () => onChanged(VcNavTab.chat),
                showNotification: hasChatNotification,
              ),
              _NavItem(
                icon: Icons.diamond_outlined,
                activeIcon: Icons.diamond_rounded,
                iconSize: 24,
                active: current == VcNavTab.daily5,
                onTap: () => onChanged(VcNavTab.daily5),
              ),
              _NavItem(
                icon: Icons.shield_outlined,
                active: current == VcNavTab.trust,
                onTap: () => onChanged(VcNavTab.trust),
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
    this.activeIcon,
    this.iconSize = 22,
    this.showNotification = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final double iconSize;
  final bool active;
  final VoidCallback onTap;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.violet : AppColors.textMuted;
    final displayIcon = active ? (activeIcon ?? icon) : icon;

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
                Icon(displayIcon, size: iconSize, color: color),
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
