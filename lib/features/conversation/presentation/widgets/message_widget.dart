import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == 'user';
    final responsive = context.responsive;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              responsive.width *
              responsive.responsive(mobile: 0.8, tablet: 0.7, desktop: 0.6),
        ),
        margin: EdgeInsets.only(
          bottom: responsive.responsive(mobile: 4.0, tablet: 6.0, desktop: 8.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.responsive(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
          vertical: responsive.responsive(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF6366F1) : const Color(0xFF242424),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(responsive.borderRadius),
            topRight: Radius.circular(responsive.borderRadius),
            bottomLeft: Radius.circular(isUser ? responsive.borderRadius : 4),
            bottomRight: Radius.circular(isUser ? 4 : responsive.borderRadius),
          ),
          border: Border.all(
            color: isUser
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
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
                      : Colors.white.withValues(alpha: isUser ? 1.0 : 0.9),
                  fontSize: responsive.fontSize(15),
                  fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            if (message.status == MessageStatus.pending) ...[
              SizedBox(
                width: responsive.responsive(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              SizedBox(
                width: responsive.responsive(
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                height: responsive.responsive(
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUser
                        ? Colors.white.withValues(alpha: 0.8)
                        : const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
            if (message.status == MessageStatus.failed) ...[
              SizedBox(
                width: responsive.responsive(
                  mobile: 8.0,
                  tablet: 10.0,
                  desktop: 12.0,
                ),
              ),
              Icon(
                Icons.error_outline_rounded,
                size: responsive.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
                color: const Color(0xFFEF4444),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
