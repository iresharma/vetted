import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/photo_storage_service.dart';
import 'package:vetted_club_mobile/core/services/profile_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_photo_grid.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_verified_identity_card.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileYouAndPhotosScreen extends StatefulWidget {
  const ProfileYouAndPhotosScreen({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  static const maxPhotos = 6;

  @override
  State<ProfileYouAndPhotosScreen> createState() =>
      _ProfileYouAndPhotosScreenState();
}

class _ProfileYouAndPhotosScreenState extends State<ProfileYouAndPhotosScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  String? _verifiedName;
  int? _verifiedAge;
  late List<ProfilePhotoSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = List.generate(
      ProfileYouAndPhotosScreen.maxPhotos,
      (_) => const ProfilePhotoSlot(),
    );
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final draft = await ProfileService.instance.loadDraft();
      if (!mounted) return;

      final slots = List<ProfilePhotoSlot>.generate(
        ProfileYouAndPhotosScreen.maxPhotos,
        (_) => const ProfilePhotoSlot(),
      );
      for (var i = 0; i < draft.photoUrls.length && i < slots.length; i++) {
        slots[i] = ProfilePhotoSlot(remoteUrl: draft.photoUrls[i]);
      }

      setState(() {
        _verifiedName = draft.verifiedName;
        _verifiedAge = draft.verifiedAge;
        _slots = slots;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load your profile. Check your connection.';
        _loading = false;
      });
    }
  }

  int? get _nextEmptyIndex {
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i].isEmpty) return i;
    }
    return null;
  }

  int get _filledCount => _slots.where((slot) => slot.isFilled).length;

  bool get _hasUploadInProgress => _slots.any((slot) => slot.uploading);

  bool get _canContinue =>
      !_loading && !_saving && !_hasUploadInProgress && _filledCount >= 1;

  List<String> get _photoUrls => [
        for (final slot in _slots)
          if (slot.remoteUrl != null) slot.remoteUrl!,
      ];

  Future<void> _pickPhoto(int index) async {
    final file = await PhotoStorageService.instance.pickFromGallery();
    if (file == null || !mounted) return;

    setState(() {
      _slots[index] = ProfilePhotoSlot(
        localPath: file.path,
        uploading: true,
      );
    });

    try {
      final url = await PhotoStorageService.instance.uploadProfilePhoto(file);
      if (!mounted) return;
      setState(() {
        _slots[index] = ProfilePhotoSlot(remoteUrl: url);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _slots[index] = const ProfilePhotoSlot());
      _showMessage('Photo upload failed. Please try again.');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      final updated = List<ProfilePhotoSlot>.from(_slots);
      updated.removeAt(index);
      updated.add(const ProfilePhotoSlot());
      _slots = updated;
    });
  }

  Future<void> _saveAndContinue() async {
    if (!_canContinue) return;

    setState(() => _saving = true);
    try {
      await ProfileService.instance.savePhotoUrls(_photoUrls);
      if (!mounted) return;
      widget.onContinue();
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save photos. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const RegistrationScaffold(
        header: ProfileStepHeader(stepIndex: 0),
        ctaLabel: 'Continue →',
        ctaEnabled: false,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 48),
            child: CircularProgressIndicator(
              color: AppColors.violet,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_loadError != null) {
      return RegistrationScaffold(
        header: const ProfileStepHeader(stepIndex: 0),
        ctaLabel: 'Retry',
        onCta: _loadDraft,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _loadError!,
              style: AppTypography.body(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RegistrationScaffold(
      header: const ProfileStepHeader(stepIndex: 0),
      ctaLabel: 'Continue →',
      ctaEnabled: _canContinue,
      ctaLoading: _saving,
      onCta: _saveAndContinue,
      footerCaption: _filledCount == 0
          ? 'Add at least one photo to continue'
          : '$_filledCount of ${ProfileYouAndPhotosScreen.maxPhotos} photos',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You &\nyour photos.',
            style: AppTypography.display().copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your name and age are locked from verification. '
            'Add up to six photos — first one is your main shot.',
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          VcVerifiedIdentityCard(
            name: _verifiedName,
            age: _verifiedAge,
          ),
          const SizedBox(height: 24),
          Text(
            'Photos',
            style: AppTypography.eyebrow(color: AppColors.violet),
          ),
          const SizedBox(height: 12),
          VcPhotoGrid(
            slots: _slots,
            maxPhotos: ProfileYouAndPhotosScreen.maxPhotos,
            onAdd: (index) {
              if (_slots[index].isEmpty) {
                _pickPhoto(index);
              } else if (_nextEmptyIndex != null) {
                _pickPhoto(_nextEmptyIndex!);
              }
            },
            onRemove: _removePhoto,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.s1,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border(
                left: BorderSide(color: AppColors.violet, width: 3),
              ),
            ),
            child: Text(
              'Show your face clearly in at least one photo. '
              'No group shots as your main pic.',
              style: AppTypography.supporting(color: AppColors.textSecondary)
                  .copyWith(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
