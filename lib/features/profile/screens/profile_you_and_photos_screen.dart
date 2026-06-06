import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/photo_storage_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_schema.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_section_hydration.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_flow_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_section_notifier.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_field_renderer.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_section_loading_scaffold.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_step_header.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_photo_grid.dart';
import 'package:vetted_club_mobile/features/profile/widgets/vc_verified_identity_card.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileYouAndPhotosScreen extends ConsumerStatefulWidget {
  const ProfileYouAndPhotosScreen({super.key});

  @override
  ConsumerState<ProfileYouAndPhotosScreen> createState() =>
      _ProfileYouAndPhotosScreenState();
}

class _ProfileYouAndPhotosScreenState
    extends ConsumerState<ProfileYouAndPhotosScreen> {
  static const sectionId = 'you_and_photos';
  static const maxPhotos = 8;

  late List<ProfilePhotoSlot> _slots;
  bool _photosHydrated = false;

  @override
  void initState() {
    super.initState();
    _slots = List.generate(maxPhotos, (_) => const ProfilePhotoSlot());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryHydratePhotos());
  }

  void _tryHydratePhotos() {
    if (_photosHydrated || !mounted) return;
    _hydratePhotosFromDraft(ref.read(profileDraftProvider).value);
  }

  void _hydratePhotosFromDraft(ProfileDraft? draft) {
    if (_photosHydrated || draft == null) return;
    if (_filledCount > 0) {
      _photosHydrated = true;
      return;
    }

    final urls = draft.values['photo_urls'];
    if (urls is! List) {
      _photosHydrated = true;
      return;
    }

    final slots = List<ProfilePhotoSlot>.generate(
      maxPhotos,
      (_) => const ProfilePhotoSlot(),
    );
    for (var i = 0; i < urls.length && i < slots.length; i++) {
      slots[i] = ProfilePhotoSlot(remoteUrl: urls[i].toString());
    }
    final photoUrls = [
      for (final slot in slots)
        if (slot.remoteUrl != null) slot.remoteUrl!,
    ];
    setState(() {
      _photosHydrated = true;
      _slots = slots;
    });
    ref.read(profileSectionProvider(sectionId).notifier).setValue(
          'photo_urls',
          photoUrls,
        );
  }

  int get _filledCount => _slots.where((s) => s.isFilled).length;

  bool get _hasUploadInProgress => _slots.any((s) => s.uploading);

  List<String> get _photoUrls => [
        for (final slot in _slots)
          if (slot.remoteUrl != null) slot.remoteUrl!,
      ];

  Future<void> _pickPhoto(int index) async {
    final file = await PhotoStorageService.instance.pickFromGallery();
    if (file == null || !mounted) return;

    setState(() {
      _slots[index] = ProfilePhotoSlot(localPath: file.path, uploading: true);
    });

    try {
      final url = await PhotoStorageService.instance.uploadProfilePhoto(file);
      if (!mounted) return;
      setState(() {
        _slots[index] = ProfilePhotoSlot(remoteUrl: url);
      });
      ref.read(profileSectionProvider(sectionId).notifier).setValue(
            'photo_urls',
            _photoUrls,
          );
    } on PhotoUploadException catch (e) {
      if (!mounted) return;
      setState(() => _slots[index] = const ProfilePhotoSlot());
      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('Photo upload error: $e');
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
    ref.read(profileSectionProvider(sectionId).notifier).setValue(
          'photo_urls',
          _photoUrls,
        );
  }

  Future<void> _saveAndContinue() async {
    ref.read(profileSectionProvider(sectionId).notifier).setValue(
          'photo_urls',
          _photoUrls,
        );
    final ok =
        await ref.read(profileSectionProvider(sectionId).notifier).save();
    if (!ok || !mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(profileFlowProvider.notifier).nextFrom(ProfileFlowStep.youAndPhotos);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileDraftProvider, (previous, next) {
      if (!next.hasValue || _photosHydrated) return;
      Future.microtask(() {
        if (mounted) _hydratePhotosFromDraft(next.value);
      });
    });

    final draftAsync = ref.watch(profileDraftProvider);
    final draft = draftAsync.value;

    final ready = ProfileSectionHydration.isReady(
      ref: ref,
      sectionId: sectionId,
      probeKeys: ProfileSectionProbeKeys.youAndPhotos,
    );

    if (!ready) {
      return const ProfileSectionLoadingScaffold(stepIndex: 0);
    }

    final sectionState = ref.watch(profileSectionProvider(sectionId));
    final notifier = ref.read(profileSectionProvider(sectionId).notifier);
    final form = sectionState.formState;
    final canContinue = sectionState.canContinue &&
        !_hasUploadInProgress &&
        _filledCount >= 3;
    final identityLoading =
        draftAsync.isLoading && draft?.verifiedName == null;

    return RegistrationScaffold(
      header: const ProfileStepHeader(stepIndex: 0),
      ctaLabel: 'Continue →',
      ctaEnabled: canContinue,
      ctaLoading: sectionState.saving,
      onCta: _saveAndContinue,
      footerCaption: _filledCount < 3
          ? 'Add at least 3 photos to continue'
          : '${sectionState.requiredRemaining} required fields left',
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
            'Add up to eight photos — first one is your main shot.',
            style: AppTypography.body(color: AppColors.textSecondary).copyWith(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          if (draftAsync.hasError && draft == null) ...[
            const SizedBox(height: 16),
            _DraftLoadBanner(
              onRetry: () => ref.invalidate(profileDraftProvider),
            ),
          ],
          const SizedBox(height: 24),
          VcVerifiedIdentityCard(
            name: draft?.verifiedName,
            age: draft?.verifiedAge,
            loading: identityLoading,
          ),
          const SizedBox(height: 24),
          for (final field in form.visibleFields)
            if (field.type == ProfileFieldType.photoUpload)
              ProfileFieldRenderer(
                field: field,
                sectionId: sectionId,
                value: _photoUrls,
                photoSlots: _slots,
                maxPhotos: maxPhotos,
                onPhotoAdd: _pickPhoto,
                onPhotoRemove: _removePhoto,
                onChanged: (_) {},
              )
            else
              ProfileFieldRenderer(
                field: field,
                sectionId: sectionId,
                value: form.valueFor(field.id),
                onChanged: (v) => notifier.setValue(field.id, v),
              ),
        ],
      ),
    );
  }
}

class _DraftLoadBanner extends StatelessWidget {
  const _DraftLoadBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amberDim,
        borderRadius: AppRadius.r12,
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Could not sync saved profile data. You can still fill the form.',
              style: AppTypography.supporting(color: AppColors.amber),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTypography.supporting(color: AppColors.amber).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
