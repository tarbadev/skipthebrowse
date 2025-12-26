import 'package:flutter/material.dart';
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

  Widget _buildProviderLogo(String slug) {
    final assetPath = 'assets/images/providers/$slug.png';

    return Image.asset(
      assetPath,
      height: 20,
      width: 20,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if logo doesn't exist
        return const Icon(Icons.play_circle_outline, size: 20);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('recommendation_${recommendation.id}_card'),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 4,
      color: const Color(0xFF242424),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(recommendation.confidence * 100).toStringAsFixed(0)}% match',
                    key: Key('recommendation_${recommendation.id}_confidence'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              recommendation.title,
              key: Key('recommendation_${recommendation.id}_title'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Release year and rating row
            Row(
              children: [
                if (recommendation.releaseYear != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${recommendation.releaseYear}',
                      key: Key(
                        'recommendation_${recommendation.id}_release_year',
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (recommendation.rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFBBF24),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recommendation.rating!.toStringAsFixed(1),
                          key: Key(
                            'recommendation_${recommendation.id}_rating',
                          ),
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty) ...[
              Text(
                recommendation.description!,
                key: Key('recommendation_${recommendation.id}_description'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Platforms section
            Text(
              'Available on',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendation.platforms.asMap().entries.map((entry) {
                final index = entry.key;
                final platform = entry.value;
                final isPreferred = platform.isPreferred;

                return _PlatformButton(
                  platformId: '${recommendation.id}_platform_$index',
                  platform: platform,
                  isPreferred: isPreferred,
                  providerLogo: _buildProviderLogo(platform.slug),
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
    return ElevatedButton(
      key: Key('recommendation_${widget.platformId}'),
      onPressed: widget.onPressed,
      style:
          ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            backgroundColor: widget.isPreferred
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.05),
            foregroundColor: Colors.white.withOpacity(0.9),
            side: BorderSide(
              color: widget.isPreferred
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
              return Colors.white.withOpacity(0.05);
            }),
            side: WidgetStateProperty.resolveWith<BorderSide>((
              Set<WidgetState> states,
            ) {
              if (widget.isPreferred) {
                return const BorderSide(color: Colors.transparent, width: 1.5);
              }
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                );
              }
              return BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              );
            }),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.providerLogo,
          const SizedBox(width: 8),
          Text(
            widget.platform.name,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.isPreferred) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ],
      ),
    );
  }
}
