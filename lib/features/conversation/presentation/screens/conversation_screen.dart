import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/message_widget.dart';

import '../../domain/entities/conversation.dart';

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
  Widget build(BuildContext context) {
    final messages = widget.conversation.messages.map(
      (c) => MessageWidget(c.content),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Center(
        child: Column(
          children: [
            Text(
              'Conversation ID: ${widget.conversation.id}',
              key: const Key('conversation_screen_title'),
            ),
            ...messages,
          ],
        ),
      ),
    );
  }
}
