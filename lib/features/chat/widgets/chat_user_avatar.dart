import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';

/// Circular avatar for chat surfaces — uses profile photo when available.
class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 48,
    this.highlightUnread = false,
  });

  final String? photoUrl;
  final String name;
  final double size;
  final bool highlightUnread;

  @override
  Widget build(BuildContext context) {
    final displayName = cleanDailyDisplayName(name);
    final initial = dailyProfileInitial(displayName);
    final url = photoUrl?.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.s2,
        border: Border.all(
          color: highlightUnread ? AppColors.coral : AppColors.border,
          width: highlightUnread ? 1.5 : 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialFallback(
                initial: initial,
                size: size,
              ),
            )
          : _InitialFallback(initial: initial, size: size),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({required this.initial, required this.size});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.s2,
      child: Center(
        child: Text(
          initial,
          style: AppTypography.title().copyWith(fontSize: size * 0.38),
        ),
      ),
    );
  }
}
