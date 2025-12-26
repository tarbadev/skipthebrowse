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

    final conversationStarters = [
      "I want something thrilling to watch",
      "Looking for a comedy series to binge",
      "Recommend me something like Inception",
    ];

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Looking for something to watch?',
                key: Key('home_page_title'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Try one of these:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: conversationStarters.map((starter) {
                  return ActionChip(
                    label: Text(starter),
                    onPressed: isLoading
                        ? null
                        : () => _createConversation(starter, ref, context),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text(
                'Or start your own:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              AddMessageWidget(
                onSubmit: (String message) =>
                    _createConversation(message, ref, context),
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
