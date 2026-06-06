import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

/// Local or remote photo in a profile slot.
class ProfilePhotoSlot {
  const ProfilePhotoSlot({
    this.remoteUrl,
    this.localPath,
    this.uploading = false,
  });

  final String? remoteUrl;
  final String? localPath;
  final bool uploading;

  bool get isEmpty => remoteUrl == null && localPath == null;
  bool get isFilled => !isEmpty;

  ProfilePhotoSlot copyWith({
    String? remoteUrl,
    String? localPath,
    bool? uploading,
    bool clearRemote = false,
    bool clearLocal = false,
  }) {
    return ProfilePhotoSlot(
      remoteUrl: clearRemote ? null : (remoteUrl ?? this.remoteUrl),
      localPath: clearLocal ? null : (localPath ?? this.localPath),
      uploading: uploading ?? this.uploading,
    );
  }
}

class VcPhotoGrid extends StatelessWidget {
  const VcPhotoGrid({
    super.key,
    required this.slots,
    required this.maxPhotos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ProfilePhotoSlot> slots;
  final int maxPhotos;
  final void Function(int index) onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: maxPhotos,
      itemBuilder: (context, index) {
        final slot = index < slots.length ? slots[index] : const ProfilePhotoSlot();
        final isPrimary = index == 0;

        return _PhotoSlotTile(
          index: index,
          slot: slot,
          isPrimary: isPrimary,
          onTap: () {
            if (slot.isFilled && !slot.uploading) {
              onRemove(index);
            } else if (!slot.uploading) {
              onAdd(index);
            }
          },
        );
      },
    );
  }
}

class _PhotoSlotTile extends StatelessWidget {
  const _PhotoSlotTile({
    required this.index,
    required this.slot,
    required this.isPrimary,
    required this.onTap,
  });

  final int index;
  final ProfilePhotoSlot slot;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = slot.isFilled;
    final active = isPrimary && !filled;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.s2,
          borderRadius: AppRadius.r12,
          border: Border.all(
            color: active ? AppColors.violet : AppColors.border,
            width: active ? 1.5 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.violetDark.withValues(alpha: 0.55),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.r12,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (filled) _PhotoPreview(slot: slot) else _EmptySlot(index: index, isPrimary: isPrimary),
              if (slot.uploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: const VcLoadingIndicator(
                    logoSize: 32,
                    compact: true,
                    withGlow: false,
                  ),
                ),
              if (filled && !slot.uploading)
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.bg.withValues(alpha: 0.82),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              if (isPrimary && filled)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MAIN',
                      style: AppTypography.microLabel(color: AppColors.onViolet)
                          .copyWith(fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.index, required this.isPrimary});

  final int index;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, size: 26, color: AppColors.violet),
          const SizedBox(height: 2),
          Text(
            'ADD',
            style: AppTypography.microLabel(color: AppColors.violet),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        '${index + 1}',
        style: AppTypography.supporting(color: AppColors.textMuted)
            .copyWith(fontSize: 13),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.slot});

  final ProfilePhotoSlot slot;

  @override
  Widget build(BuildContext context) {
    if (slot.localPath != null && !kIsWeb) {
      return Image.file(
        File(slot.localPath!),
        fit: BoxFit.cover,
      );
    }

    if (slot.remoteUrl != null) {
      return Image.network(
        slot.remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.s3,
          child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
        ),
      );
    }

    return const ColoredBox(color: AppColors.s3);
  }
}
