import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/add_message_widget.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/message_widget.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/recommendation_widget.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/providers/conversation_providers.dart';
import '../widgets/quick_reply_widget.dart';

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
    final currentConversation = conversationState.value ?? widget.conversation;
    final isLoading = conversationState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversation ID: ${widget.conversation.id}',
          key: const Key('conversation_screen_title'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: currentConversation.messages.map((message) {
                return Column(
                  key: Key('message_column_${message.id}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: MessageWidget(message),
                    ),
                    if (message.type == MessageType.recommendation &&
                        message.recommendation != null)
                      RecommendationWidget(
                        recommendation: message.recommendation!,
                      ),
                    if (message.author == 'assistant' &&
                        message.quickReplies != null &&
                        message.quickReplies!.isNotEmpty)
                      QuickReplyWidget(
                        replies: message.quickReplies!,
                        onReplyTap: (reply) => _addMessage(reply),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: AddMessageWidget(
              onSubmit: _addMessage,
              isLoading: isLoading,
              minLength: 2,
            ),
          ),
        ],
      ),
    );
  }
}
