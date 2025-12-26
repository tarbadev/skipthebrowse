import 'package:flutter/material.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6366F1) : const Color(0xFF242424),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.status == MessageStatus.failed
                      ? const Color(0xFFEF4444)
                      : Colors.white.withOpacity(isUser ? 1.0 : 0.9),
                  fontSize: 15,
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            if (message.status == MessageStatus.pending) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUser
                        ? Colors.white.withOpacity(0.8)
                        : const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
            if (message.status == MessageStatus.failed) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: Color(0xFFEF4444),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
