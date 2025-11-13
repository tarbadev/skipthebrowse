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
    final conversationRepository = ref.read(conversationRepositoryProvider);
    final conversation = await conversationRepository.createConversation(
      _message,
    );
    widget.callback(conversation);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
          ),
        ),
        IconButton(
          key: Key('create_conversation_button'),
          icon: Icon(Icons.send),
          onPressed: _createConversation,
        ),
      ],
    );
  }
}
