import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';

import '../../domain/providers/conversation_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _createConversation(
    String message,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final conversation = await ref
        .read(conversationStateProvider.notifier)
        .createConversation(message);

    if (conversation != null && context.mounted) {
      AppRoutes.goToConversation(context, conversation);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(conversationStateProvider);
    final isLoading = conversationState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SkipTheBrowse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => AppRoutes.goToConversationList(context),
            tooltip: 'View past conversations',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Looking for something to watch?',
              key: Key('home_page_title'),
            ),
            AddMessageWidget(
              onSubmit: (String message) =>
                  _createConversation(message, ref, context),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
