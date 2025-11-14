import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';

typedef CreationSuccessCallback = void Function(Conversation);

class CreateConversationWidget extends ConsumerStatefulWidget {
  final CreationSuccessCallback callback;

  const CreateConversationWidget({super.key, required this.callback});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CreateConversationWidget();
  }
}

class _CreateConversationWidget
    extends ConsumerState<CreateConversationWidget> {
  String _message = '';

  void _updateMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<void> _createConversation() async {
    await ref
        .read(conversationCreateStateProvider.notifier)
        .createConversation(_message);
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationCreateStateProvider);

    ref.listen<AsyncValue<Conversation?>>(conversationCreateStateProvider, (
      previous,
      next,
    ) {
      next.whenData((conversation) {
        if (conversation != null) {
          widget.callback(conversation);
          ref.read(conversationCreateStateProvider.notifier).clear();
        }
      });
    });

    final isLoading = conversationState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: Key('create_conversation_text_box'),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText:
                      'Enter a brief description of what you would like to watch',
                  filled: true,
                ),
                onChanged: _updateMessage,
                enabled: !isLoading,
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                key: Key('create_conversation_button'),
                icon: Icon(Icons.send),
                onPressed: _message.isNotEmpty ? _createConversation : null,
              ),
          ],
        ),
        conversationState.when(
          data: (_) => SizedBox.shrink(),
          loading: () => SizedBox.shrink(),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${error.toString()}',
              key: Key('create_conversation_error'),
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
