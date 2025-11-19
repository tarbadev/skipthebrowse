import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/config/router.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/providers/conversation_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _createConversation(String message, WidgetRef ref) async =>
      await ref
          .read(conversationCreateStateProvider.notifier)
          .createConversation(message);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(conversationCreateStateProvider);

    ref.listen<AsyncValue<Conversation?>>(conversationCreateStateProvider, (
      previous,
      next,
    ) {
      next.whenData((conversation) {
        if (conversation != null) {
          AppRoutes.goToConversation(context, conversation);
          ref.read(conversationCreateStateProvider.notifier).clear();
        }
      });
    });

    final isLoading = conversationState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('SkipTheBrowse'),
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
              onSubmit: (String message) => _createConversation(message, ref),
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
