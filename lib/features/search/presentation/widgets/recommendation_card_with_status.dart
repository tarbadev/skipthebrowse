import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationCardWithStatus extends StatelessWidget {
  final RecommendationWithStatus recommendation;
  final Function(RecommendationStatus)? onStatusChange;

  const RecommendationCardWithStatus({
    super.key,
    required this.recommendation,
    this.onStatusChange,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open link. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildProviderLogo(BuildContext context, String slug) {
    final assetPath = 'assets/images/providers/$slug.png';
    final responsive = context.responsive;
    final logoSize = responsive.responsive(
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );

    return Image.asset(
      assetPath,
      height: logoSize,
      width: logoSize,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.play_circle_outline, size: logoSize);
      },
    );
  }

  Color _getStatusColor(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.proposed:
        return const Color(0xFF6366F1);
      case RecommendationStatus.willWatch:
        return const Color(0xFF10B981);
      case RecommendationStatus.seen:
        return const Color(0xFF8B5CF6);
      case RecommendationStatus.declined:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusLabel(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.proposed:
        return 'Suggested';
      case RecommendationStatus.willWatch:
        return 'Will Watch';
      case RecommendationStatus.seen:
        return 'Seen';
      case RecommendationStatus.declined:
        return 'Not Interested';
    }
  }

  IconData _getStatusIcon(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.proposed:
        return Icons.auto_awesome_rounded;
      case RecommendationStatus.willWatch:
        return Icons.bookmark_rounded;
      case RecommendationStatus.seen:
        return Icons.check_circle_rounded;
      case RecommendationStatus.declined:
        return Icons.block_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Card(
      key: Key('recommendation_${recommendation.id}_card'),
      margin: EdgeInsets.symmetric(
        vertical: responsive.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        ),
        horizontal: responsive.responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
      ),
      elevation: responsive.cardElevation,
      color: const Color(0xFF242424),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        side: BorderSide(
          color: _getStatusColor(recommendation.status).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          responsive.responsive(mobile: 20.0, tablet: 22.0, desktop: 24.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and confidence badges
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.responsive(
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(recommendation.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(recommendation.status),
                        size: responsive.responsive(
                          mobile: 14.0,
                          tablet: 15.0,
                          desktop: 16.0,
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: responsive.responsive(
                          mobile: 6.0,
                          tablet: 7.0,
                          desktop: 8.0,
                        ),
                      ),
                      Text(
                        _getStatusLabel(recommendation.status),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.responsive(
                      mobile: 10.0,
                      tablet: 12.0,
                      desktop: 14.0,
                    ),
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(recommendation.confidence * 100).toStringAsFixed(0)}% match',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: responsive.fontSize(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: responsive.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
            ),

            // Title
            Text(
              recommendation.title,
              key: Key('recommendation_${recommendation.id}_title'),
              style: TextStyle(
                fontSize: responsive.fontSize(24),
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(
              height: responsive.responsive(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
            ),

            // Release year and rating row
            Row(
              children: [
                if (recommendation.releaseYear != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.responsive(
                        mobile: 10.0,
                        tablet: 11.0,
                        desktop: 12.0,
                      ),
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${recommendation.releaseYear}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: responsive.fontSize(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: responsive.responsive(
                      mobile: 8.0,
                      tablet: 9.0,
                      desktop: 10.0,
                    ),
                  ),
                ],
                if (recommendation.rating != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.responsive(
                        mobile: 10.0,
                        tablet: 11.0,
                        desktop: 12.0,
                      ),
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFBBF24),
                          size: responsive.responsive(
                            mobile: 16.0,
                            tablet: 17.0,
                            desktop: 18.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            color: const Color(0xFFFBBF24),
                            fontSize: responsive.fontSize(13),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty) ...[
              SizedBox(
                height: responsive.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
              Text(
                recommendation.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: responsive.fontSize(15),
                  height: 1.5,
                ),
              ),
            ],

            // Action buttons
            if (onStatusChange != null) ...[
              SizedBox(
                height: responsive.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
              Wrap(
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
                children: [
                  if (recommendation.status != RecommendationStatus.seen)
                    _StatusActionButton(
                      label: 'Seen',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () =>
                          onStatusChange!(RecommendationStatus.seen),
                    ),
                  if (recommendation.status != RecommendationStatus.willWatch)
                    _StatusActionButton(
                      label: 'Will Watch',
                      icon: Icons.bookmark_border_rounded,
                      onPressed: () =>
                          onStatusChange!(RecommendationStatus.willWatch),
                    ),
                  if (recommendation.status != RecommendationStatus.declined)
                    _StatusActionButton(
                      label: 'Not Interested',
                      icon: Icons.block_rounded,
                      onPressed: () =>
                          onStatusChange!(RecommendationStatus.declined),
                    ),
                ],
              ),
            ],

            // Platforms section
            if (recommendation.platforms.isNotEmpty) ...[
              SizedBox(
                height: responsive.responsive(
                  mobile: 20.0,
                  tablet: 22.0,
                  desktop: 24.0,
                ),
              ),
              Text(
                'Available on',
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Wrap(
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
                children: recommendation.platforms.asMap().entries.map((entry) {
                  final platform = entry.value;
                  return _PlatformButton(
                    platform: platform,
                    providerLogo: _buildProviderLogo(context, platform.slug),
                    onPressed: () => _launchUrl(context, platform.url),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: responsive.responsive(mobile: 16.0, tablet: 17.0, desktop: 18.0),
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.responsive(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
          vertical: responsive.responsive(
            mobile: 10.0,
            tablet: 11.0,
            desktop: 12.0,
          ),
        ),
        foregroundColor: Colors.white.withValues(alpha: 0.8),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
      ),
    );
  }
}

class _PlatformButton extends StatelessWidget {
  final dynamic platform;
  final Widget providerLogo;
  final VoidCallback onPressed;

  const _PlatformButton({
    required this.platform,
    required this.providerLogo,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.responsive(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
          vertical: responsive.responsive(
            mobile: 12.0,
            tablet: 13.0,
            desktop: 14.0,
          ),
        ),
        backgroundColor: platform.isPreferred
            ? const Color(0xFF6366F1)
            : Colors.white.withValues(alpha: 0.05),
        side: BorderSide(
          color: platform.isPreferred
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          providerLogo,
          SizedBox(
            width: responsive.responsive(
              mobile: 8.0,
              tablet: 9.0,
              desktop: 10.0,
            ),
          ),
          Text(
            platform.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (platform.isPreferred) ...[
            SizedBox(
              width: responsive.responsive(
                mobile: 6.0,
                tablet: 7.0,
                desktop: 8.0,
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: responsive.responsive(
                mobile: 16.0,
                tablet: 17.0,
                desktop: 18.0,
              ),
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ],
      ),
    );
  }
}
