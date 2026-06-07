import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';
import 'package:vetted_club_mobile/features/chat/providers/chat_providers.dart';
import 'package:vetted_club_mobile/features/chat/widgets/chat_thread_list_tile.dart';

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(enrichedChatThreadsProvider);

    return threadsAsync.when(
      data: (threads) {
        if (threads.isEmpty) {
          return const VcEmptyState(
            imageAsset: AppAssets.emptyMailbox,
            title: 'No conversations yet',
            message:
                'When you and someone both show interest, the conversation '
                'starts here. Keep your profile sharp, show up on Daily 5, '
                'and your next match could land any day.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.xxxl,
          ),
          itemCount: threads.length,
          itemBuilder: (_, index) =>
              ChatThreadListTile(thread: threads[index]),
        );
      },
      loading: () => const Center(child: VcLoadingIndicator(compact: true)),
      error: (_, __) => const VcEmptyState(
        imageAsset: AppAssets.emptyMailbox,
        title: 'Could not load chats',
        message: 'Check your connection and try again.',
      ),
    );
  }
}
