import 'package:flutter/material.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message.content,
            style: TextStyle(
              color: message.status == MessageStatus.failed ? Colors.red : null,
            ),
          ),
        ),
        if (message.status == MessageStatus.pending)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (message.status == MessageStatus.failed)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.error_outline, size: 16, color: Colors.red),
          ),
      ],
    );
  }
}
