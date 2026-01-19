import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/presentation/utils/error_message_helper.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final message = ErrorMessageHelper.getMessage(error);
    final actionLabel = ErrorMessageHelper.getActionLabel(error);
    final isRetryable = ErrorMessageHelper.isRetryable(error);

    return Container(
      margin: EdgeInsets.symmetric(
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
      padding: EdgeInsets.all(
        responsive.responsive(mobile: 16.0, tablet: 18.0, desktop: 20.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(
          color: const Color(0xFFFF5252).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ErrorMessageHelper.getErrorIcon(error),
                style: TextStyle(fontSize: responsive.fontSize(20)),
              ),
              SizedBox(
                width: responsive.responsive(
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: responsive.fontSize(14),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            SizedBox(
              height: responsive.responsive(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(fontSize: responsive.fontSize(13)),
                    ),
                  ),
                if (onRetry != null && isRetryable) ...[
                  if (onDismiss != null)
                    SizedBox(
                      width: responsive.responsive(
                        mobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.responsive(
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                        vertical: responsive.responsive(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(fontSize: responsive.fontSize(13)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
