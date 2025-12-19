import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(conversationListStateProvider.notifier).loadConversations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationListState = ref.watch(conversationListStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pop(),
            tooltip: 'Start new conversation',
          ),
        ],
      ),
      body: conversationListState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading conversations: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(conversationListStateProvider.notifier)
                    .loadConversations(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation to get recommendations',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(conversationListStateProvider.notifier)
                .loadConversations(),
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return _ConversationListItem(
                  summary: conversations[index],
                  key: Key('conversation_item_${conversations[index].id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversationListItem extends ConsumerWidget {
  final ConversationSummary summary;

  const _ConversationListItem({required this.summary, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(child: Text(summary.messageCount.toString())),
      title: Text(
        summary.previewText,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_formatTimestamp(summary.updatedAt)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        try {
          final conversation = await ref
              .read(conversationRepositoryProvider)
              .getConversation(summary.id);

          if (context.mounted) {
            AppRoutes.goToConversation(context, conversation);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading conversation: $e')),
            );
          }
        }
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as "MMM d" (e.g., "Dec 15")
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}';
    }
  }
}
