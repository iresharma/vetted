import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/providers/daily5_session_provider.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_countdown.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_pass_reason_sheet.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_full_profile_sheet.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_score_breakdown_sheet.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_interest_sent_sheet.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_match_celebration.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_profile_card.dart';
import 'package:vetted_club_mobile/features/chat/chat_thread_launcher.dart';
import 'package:vetted_club_mobile/features/profile/data/models/profile_draft.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_draft_notifier.dart';
import 'package:vetted_club_mobile/features/profile/providers/profile_providers.dart';
import 'package:vetted_club_mobile/core/services/chat_service.dart';
import 'package:vetted_club_mobile/features/daily/utils/daily_field_labels.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_gate.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_status_notifier.dart';
import 'package:vetted_club_mobile/features/values/values_quiz_screen.dart';

class Daily5Tab extends ConsumerStatefulWidget {
  const Daily5Tab({
    super.key,
    required this.user,
    required this.isActive,
    this.onNavigate,
  });

  final User user;
  final bool isActive;
  final ValueChanged<VcNavTab>? onNavigate;

  @override
  ConsumerState<Daily5Tab> createState() => _Daily5TabState();
}

class _Daily5TabState extends ConsumerState<Daily5Tab> {
  int _currentIndex = 0;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _activate());
    }
  }

  @override
  void didUpdateWidget(Daily5Tab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _activate());
    }
  }

  void _activate() {
    ref.read(daily5SessionProvider.notifier).activate(force: true);
  }

  Widget _quiz({required ValueChanged<String> onComplete}) {
    return ValuesQuizScreen(embedded: true, onComplete: onComplete);
  }

  String _formatFaith(String? faith) {
    if (faith == null || faith.isEmpty) return '';
    return faith.replaceAll('_', ' ');
  }

  String _subtitle(DailyProfileSummary profile) {
    final parts = <String>[
      if (profile.city != null && profile.city!.isNotEmpty) profile.city!,
      if (profile.profession != null && profile.profession!.isNotEmpty)
        profile.profession!,
      if (profile.faith != null) _formatFaith(profile.faith),
    ];
    return parts.join(' · ');
  }

  Future<void> _markShown(String queueId) async {
    try {
      await DailyService.instance.markShown(queueId);
    } catch (_) {}
  }

  Future<void> _onInterested(DailyQueueEntry entry) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final result = await DailyService.instance.recordInteraction(
        targetUid: entry.profile.uid,
        type: 'interested',
      );
      if (!mounted) return;

      final isMutual = result.isMutual || entry.reverseInterested;
      final otherName = cleanDailyDisplayName(entry.profile.displayName);
      final otherInitial = dailyProfileInitial(entry.profile.displayName);
      final draft = ref.read(profileDraftProvider).value;
      final yourInitial = dailyProfileInitial(
        draft?.displayName ?? draft?.firstName,
        fallback: 'Y',
      );

      if (isMutual) {
        await Daily5MatchCelebration.show(
          context,
          otherName: otherName,
          otherInitial: otherInitial,
          yourInitial: yourInitial,
          onSayHi: () async {
            final currentName =
                draft?.displayName ?? draft?.firstName ?? 'Member';
            final currentPhoto = _primaryPhotoUrl(draft);
            try {
              final threadId = await ChatService.instance.getOrCreateThread(
                otherUid: entry.profile.uid,
                otherName: otherName,
                currentName: currentName,
                otherPhotoUrl: entry.profile.primaryPhoto,
                currentPhotoUrl: currentPhoto,
              );
              if (!mounted) return;
              await ChatThreadLauncher.open(
                context,
                threadId: threadId,
                otherUserId: entry.profile.uid,
                otherUserName: otherName,
                otherUserPhotoUrl: entry.profile.primaryPhoto,
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open chat: $e')),
              );
            }
          },
        );
      } else {
        await Daily5InterestSentSheet.show(context, name: otherName);
      }
      _advance(entry);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record interest: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _onPass(DailyQueueEntry entry) async {
    await Daily5PassReasonSheet.show(
      context,
      onSelect: (option) async {
        if (_acting) return;
        setState(() => _acting = true);
        try {
          await DailyService.instance.recordInteraction(
            targetUid: entry.profile.uid,
            type: 'passed',
            passReason: option.passReason,
            passReasonField: option.passReasonField,
          );
          if (mounted) _advance(entry);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not record pass: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _acting = false);
        }
      },
    );
  }

  void _advance(DailyQueueEntry entry) {
    _markShown(entry.id);
    setState(() => _currentIndex += 1);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    ref.listen(valuesQuizStatusProvider, (previous, next) {
      final prevPending = previous?.value?.isPending ?? true;
      final nextComplete = next.value?.isComplete ?? false;
      if (prevPending && nextComplete) {
        ref.read(daily5SessionProvider.notifier).activate(force: true);
      }
    });

    ref.listen(registrationStatusProvider, (previous, next) {
      final prevPending = previous?.value?.valuesQuizStatus == 'pending' ||
          previous?.value?.valuesQuizStatus == null;
      final nextStatus = next.value?.valuesQuizStatus;
      if (prevPending && nextStatus != null && nextStatus != 'pending') {
        ref.read(daily5SessionProvider.notifier).activate(force: true);
      }
    });

    final sessionAsync = ref.watch(daily5SessionProvider);

    return sessionAsync.when(
      loading: () {
        if (valuesQuizPending(ref)) {
          return _quiz(
            onComplete: (status) {
              ref.read(daily5SessionProvider.notifier).onQuizFinished(status);
            },
          );
        }
        return const Center(child: VcLoadingIndicator(logoSize: 56));
      },
      error: (error, _) => VcEmptyState(
        imageAsset: AppAssets.emptyMailbox,
        title: 'Could not load Daily 5',
        message: error.toString(),
      ),
      data: (session) {
        if (session == null) {
          if (valuesQuizPending(ref)) {
            return _quiz(
              onComplete: (status) {
                ref.read(daily5SessionProvider.notifier).onQuizFinished(status);
              },
            );
          }
          return const Center(child: VcLoadingIndicator(logoSize: 56));
        }

        if (session.needsQuiz) {
          return _quiz(
            onComplete: (status) {
              ref.read(daily5SessionProvider.notifier).onQuizFinished(status);
            },
          );
        }

        final queue = session.queue;
        if (queue == null) {
          return const Center(child: VcLoadingIndicator(logoSize: 56));
        }

        return _buildQueue(queue);
      },
    );
  }

  Widget _buildQueue(DailyQueueResponse queue) {
    if (queue.entries.isEmpty) {
      return Daily5Countdown(onNavigate: widget.onNavigate);
    }

    if (_currentIndex >= queue.entries.length) {
      return Daily5Countdown(
        title: 'You\'re all caught up',
        onNavigate: widget.onNavigate,
      );
    }

    final entry = queue.entries[_currentIndex];
    final profile = entry.profile;

    if (!entry.wasShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markShown(entry.id);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pick ${entry.position} of ${queue.entries.length}',
            style: AppTypography.eyebrow(color: AppColors.violet),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.only(
              top: entry.reverseInterested ? AppSpacing.sm : 0,
            ),
            child: Daily5ProfileCard(
            name: profile.displayName ?? 'Member',
            age: profile.age,
            subtitle: _subtitle(profile),
            prompts: profile.prompts,
            compatibilityScore: entry.compatibilityScore,
            matchReasonLabel: entry.matchReasonLabel,
            matchReasonField: entry.matchReasonField,
            trustTier: profile.trustTier,
            imageUrl: profile.primaryPhoto,
            tags: profile.interests,
            interestedInYou: entry.reverseInterested,
            onScoreBreakdownTap: () => Daily5ScoreBreakdownSheet.show(
              context,
              compatibilityScore: entry.compatibilityScore,
              scoreBreakdown: entry.scoreBreakdown,
              displayName: profile.displayName ?? 'Member',
              age: profile.age,
              matchReasonLabel: entry.matchReasonLabel,
              matchReasonField: entry.matchReasonField,
              onSendInterest: _acting ? null : () => _onInterested(entry),
            ),
            onFullProfileTap: () => Daily5FullProfileSheet.show(
              context,
              profile: profile,
              onPass: _acting ? null : () => _onPass(entry),
              onSendInterest: _acting ? null : () => _onInterested(entry),
            ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          VcActionButtonRow(
            onPass: _acting ? null : () => _onPass(entry),
            onInterested: _acting ? null : () => _onInterested(entry),
            interestedLabel: entry.reverseInterested ? 'Match →' : null,
          ),
        ],
      ),
    );
  }
}

String? _primaryPhotoUrl(ProfileDraft? draft) {
  final urls = draft?.values['photo_urls'];
  if (urls is List && urls.isNotEmpty) {
    final url = urls.first?.toString().trim();
    if (url != null && url.isNotEmpty) return url;
  }
  return null;
}
