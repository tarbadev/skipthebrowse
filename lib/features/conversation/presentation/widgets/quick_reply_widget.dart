import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';

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

    final responsive = context.responsive;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
        vertical: responsive.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        ),
      ),
      child: Wrap(
        spacing: responsive.responsive(
          mobile: 8.0,
          tablet: 10.0,
          desktop: 12.0,
        ),
        runSpacing: responsive.responsive(
          mobile: 8.0,
          tablet: 10.0,
          desktop: 12.0,
        ),
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
    final responsive = context.responsive;
    final fontSize = responsive.fontSize(14);

    return OutlinedButton(
      key: Key('quick_reply_${widget.reply}'),
      onPressed: widget.onTap,
      style:
          OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
              vertical: responsive.responsive(
                mobile: 10.0,
                tablet: 11.0,
                desktop: 12.0,
              ),
            ),
            backgroundColor: const Color(0xFF242424),
            foregroundColor: Colors.white.withValues(alpha: 0.85),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
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
              return Colors.white.withValues(alpha: 0.85);
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(color: Color(0xFF6366F1), width: 1.5);
              }
              return BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              );
            }),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
      child: Text(widget.reply),
    );
  }
}
