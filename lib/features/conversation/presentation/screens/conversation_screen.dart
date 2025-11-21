import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/message_widget.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/providers/conversation_providers.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ConversationScreen({super.key, required this.conversation});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ConversationScreenState();
  }
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationStateProvider.notifier)
          .setConversation(widget.conversation);
    });
  }

  Future<void> _addMessage(String message) => ref
      .read(conversationStateProvider.notifier)
      .addMessage(widget.conversation.id, message);

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationStateProvider);
    final currentConversation =
        conversationState.asData?.value ?? widget.conversation;
    final isLoading = conversationState.isLoading;

    final messages = currentConversation.messages.map(
      (c) => MessageWidget(c.content),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Center(
        child: Column(
          children: [
            Text(
              'Conversation ID: ${currentConversation.id}',
              key: const Key('conversation_screen_title'),
            ),
            ...messages,
            AddMessageWidget(onSubmit: _addMessage, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
