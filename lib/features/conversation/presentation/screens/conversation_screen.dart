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
      backgroundColor: const Color(0xFF181818),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818).withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Conversation',
            key: Key('conversation_screen_title'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Atmospheric background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.5,
                  colors: [
                    const Color(0xFF242424).withValues(alpha: 0.6),
                    const Color(0xFF181818),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 100, bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentConversation.messages.length,
                  itemBuilder: (context, index) {
                    final message = currentConversation.messages[index];
                    return Column(
                      key: Key('message_column_${message.id}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
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
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF181818).withValues(alpha: 0.0),
                      const Color(0xFF181818),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: AddMessageWidget(
                  onSubmit: _addMessage,
                  isLoading: isLoading,
                  minLength: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
