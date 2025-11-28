import 'package:flutter/material.dart';

typedef OnReplyTapCallback = void Function(String);

class QuickReplyWidget extends StatelessWidget {
  final List<String> replies;
  final OnReplyTapCallback onReplyTap;

  const QuickReplyWidget({
    super.key,
    required this.replies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((reply) {
          return OutlinedButton(
            key: Key('quick_reply_$reply'),
            onPressed: () => onReplyTap(reply),
            child: Text(reply),
          );
        }).toList(),
      ),
    );
  }
}
