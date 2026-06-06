import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/services/daily_service.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/daily/providers/daily5_session_provider.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_countdown.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_pass_reason_sheet.dart';
import 'package:vetted_club_mobile/features/daily/widgets/daily5_profile_card.dart';
import 'package:vetted_club_mobile/features/values/providers/values_quiz_gate.dart';
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
    ref.read(daily5SessionProvider.notifier).activate();
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
      if (result.isMutual) {
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => VcMatchOverlay(
            otherName: entry.profile.displayName ?? 'them',
            otherInitial: (entry.profile.displayName ?? 'P').characters.first,
            onSayHi: () => Navigator.of(ctx).pop(),
          ),
        );
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
          Daily5ProfileCard(
            name: profile.displayName ?? 'Member',
            age: profile.age,
            subtitle: _subtitle(profile),
            prompts: profile.prompts,
            compatibilityScore: entry.compatibilityScore,
            matchReasonLabel: entry.matchReasonLabel,
            matchReasonField: entry.matchReasonField,
            trustTier: profile.trustTier,
            imageUrl: profile.primaryPhoto,
            tags: profile.interests.take(4).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          VcActionButtonRow(
            onPass: _acting ? null : () => _onPass(entry),
            onInterested: _acting ? null : () => _onInterested(entry),
          ),
        ],
      ),
    );
  }
}
