import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/services/registration_service.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/domain/profile_flow_finalizer.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_complete_hero.dart';
import 'package:vetted_club_mobile/features/profile/widgets/profile_membership_card_reveal.dart';
import 'package:vetted_club_mobile/features/registration/widgets/registration_scaffold.dart';

class ProfileCompleteScreen extends ConsumerStatefulWidget {
  const ProfileCompleteScreen({
    super.key,
    required this.user,
    this.onEnterClub,
  });

  final User user;
  final VoidCallback? onEnterClub;

  @override
  ConsumerState<ProfileCompleteScreen> createState() =>
      _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends ConsumerState<ProfileCompleteScreen> {
  late final ConfettiController _confetti;
  bool _syncOk = false;
  bool _syncing = true;
  bool _cardRevealed = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _onMount());
  }

  Future<void> _onMount() async {
    HapticFeedback.lightImpact();

    final syncOk = await ProfileFlowFinalizer.flushToBackend(ref);
    await ref.read(profileDraftProvider.notifier).reload(mergeWithLocal: true);
    await ref.read(registrationStatusProvider.notifier).refresh(widget.user.uid);

    if (mounted) {
      setState(() {
        _syncOk = syncOk;
        _syncing = false;
      });
    }
  }

  void _onCardRevealed() {
    if (_cardRevealed) return;
    setState(() => _cardRevealed = true);
    _confetti.play();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _memberId {
    final uid = widget.user.uid;
    if (uid.length < 8) return uid.toUpperCase();
    return 'VC-${uid.substring(0, 4).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final draft = ProfileFlowFinalizer.mergedDraft(ref);
    final firstName = _firstName(draft);

    return Stack(
      children: [
        RegistrationScaffold(
          scrollBody: false,
          bodyPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          footerPadding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          ctaLabel: 'Enter the club →',
          onCta: () async {
            if (!_syncOk) {
              await ProfileFlowFinalizer.flushToBackend(ref);
            }
            try {
              final status = await RegistrationService.instance
                  .enterClub(widget.user.uid);
              ref.read(registrationStatusProvider.notifier).cache(status);
            } catch (_) {
              await ref
                  .read(registrationStatusProvider.notifier)
                  .refresh(widget.user.uid);
            }
            widget.onEnterClub?.call();
          },
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileCompleteHero(
                startWhen: !_syncing,
                title: 'Welcome to\nthe club.',
                subtitle: '$firstName, your membership is ready.',
              ),
              Expanded(
                child: _syncing
                    ? const Center(
                        child: VcLoadingIndicator(logoSize: 64),
                      )
                    : Center(
                        child: ProfileMembershipCardReveal(
                          draft: draft,
                          memberId: _memberId,
                          onRevealComplete: _onCardRevealed,
                        ),
                      ),
              ),
              if (!_syncing && !_syncOk) ...[
                Text(
                  'Saved on this device — sync when you\'re back online.',
                  textAlign: TextAlign.center,
                  style: AppTypography.supporting(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
              ],
              AnimatedOpacity(
                opacity: _cardRevealed ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Daily 5 matches unlock when you enter.',
                    textAlign: TextAlign.center,
                    style: AppTypography.supporting(color: AppColors.textMuted)
                        .copyWith(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 24,
            maxBlastForce: 26,
            minBlastForce: 10,
            gravity: 0.14,
            colors: const [
              AppColors.amber,
              AppColors.violet,
              AppColors.mint,
            ],
          ),
        ),
      ],
    );
  }

  String _firstName(ProfileDraft draft) => draft.firstName;
}
