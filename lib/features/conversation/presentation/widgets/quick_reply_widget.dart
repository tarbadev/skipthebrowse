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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((reply) {
          return _QuickReplyChip(reply: reply, onTap: () => onReplyTap(reply));
        }).toList(),
      ),
    );
  }
}

class _QuickReplyChip extends StatefulWidget {
  final String reply;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.reply, required this.onTap});

  @override
  State<_QuickReplyChip> createState() => _QuickReplyChipState();
}

class _QuickReplyChipState extends State<_QuickReplyChip> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: Key('quick_reply_${widget.reply}'),
      onPressed: widget.onTap,
      style:
          OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor: const Color(0xFF242424),
            foregroundColor: Colors.white.withOpacity(0.85),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFF6366F1);
              }
              return const Color(0xFF242424);
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white;
              }
              return Colors.white.withOpacity(0.85);
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(color: Color(0xFF6366F1), width: 1.5);
              }
              return BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              );
            }),
            textStyle: WidgetStateProperty.resolveWith<TextStyle>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                );
              }
              return const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              );
            }),
          ),
      child: Text(widget.reply),
    );
  }
}
