import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/recommendation.dart';

class RecommendationWidget extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationWidget({super.key, required this.recommendation});

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
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
            // Badge
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
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
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
                    '${(recommendation.confidence * 100).toStringAsFixed(0)}% match',
                    key: Key('recommendation_${recommendation.id}_confidence'),
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
                fontSize: responsive.fontSize(26),
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
                      key: Key(
                        'recommendation_${recommendation.id}_release_year',
                      ),
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
                          key: Key(
                            'recommendation_${recommendation.id}_rating',
                          ),
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
            SizedBox(
              height: responsive.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              ),
            ),

            // Description
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty) ...[
              Text(
                recommendation.description!,
                key: Key('recommendation_${recommendation.id}_description'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: responsive.fontSize(15),
                  height: 1.5,
                ),
              ),
              SizedBox(
                height: responsive.responsive(
                  mobile: 20.0,
                  tablet: 22.0,
                  desktop: 24.0,
                ),
              ),
            ],

            // Platforms section
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
                final index = entry.key;
                final platform = entry.value;
                final isPreferred = platform.isPreferred;

                return _PlatformButton(
                  platformId: '${recommendation.id}_platform_$index',
                  platform: platform,
                  isPreferred: isPreferred,
                  providerLogo: _buildProviderLogo(context, platform.slug),
                  onPressed: () => _launchUrl(context, platform.url),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformButton extends StatefulWidget {
  final String platformId;
  final Platform platform;
  final bool isPreferred;
  final Widget providerLogo;
  final VoidCallback onPressed;

  const _PlatformButton({
    required this.platformId,
    required this.platform,
    required this.isPreferred,
    required this.providerLogo,
    required this.onPressed,
  });

  @override
  State<_PlatformButton> createState() => _PlatformButtonState();
}

class _PlatformButtonState extends State<_PlatformButton> {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return ElevatedButton(
      key: Key('recommendation_${widget.platformId}'),
      onPressed: widget.onPressed,
      style:
          ElevatedButton.styleFrom(
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
            backgroundColor: widget.isPreferred
                ? const Color(0xFF6366F1)
                : Colors.white.withValues(alpha: 0.05),
            foregroundColor: Colors.white.withValues(alpha: 0.9),
            side: BorderSide(
              color: widget.isPreferred
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (widget.isPreferred) {
                return const Color(0xFF6366F1);
              }
              if (states.contains(WidgetState.hovered)) {
                return const Color(0xFF2A2A2A);
              }
              return Colors.white.withValues(alpha: 0.05);
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (widget.isPreferred) {
                return const BorderSide(color: Colors.transparent, width: 1.5);
              }
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                );
              }
              return BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              );
            }),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.providerLogo,
          SizedBox(
            width: responsive.responsive(
              mobile: 8.0,
              tablet: 9.0,
              desktop: 10.0,
            ),
          ),
          Text(
            widget.platform.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.isPreferred) ...[
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
