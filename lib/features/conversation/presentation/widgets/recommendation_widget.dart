import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/recommendation.dart';

class RecommendationWidget extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationWidget({super.key, required this.recommendation});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
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
    final theme = Theme.of(context);

    return Card(
      key: Key('recommendation_${recommendation.id}_card'),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              recommendation.title,
              key: Key('recommendation_${recommendation.id}_title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Release year and rating row
            Row(
              children: [
                if (recommendation.releaseYear != null) ...[
                  Text(
                    '${recommendation.releaseYear}',
                    key: Key(
                      'recommendation_${recommendation.id}_release_year',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                ],
                if (recommendation.rating != null)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.rating!.toStringAsFixed(1),
                        key: Key('recommendation_${recommendation.id}_rating'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty)
              Text(
                recommendation.description!,
                key: Key('recommendation_${recommendation.id}_description'),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),

            // Platforms section
            Text(
              'Watch on:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendation.platforms.asMap().entries.map((entry) {
                final index = entry.key;
                final platform = entry.value;
                final isPreferred = platform.isPreferred;

                return ElevatedButton.icon(
                  key: Key(
                    'recommendation_${recommendation.id}_platform_$index',
                  ),
                  icon: _buildProviderLogo(platform.slug),
                  label: Text(platform.name),
                  style: isPreferred
                      ? ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        )
                      : ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurface,
                        ),
                  onPressed: () => _launchUrl(platform.url),
                );
              }).toList(),
            ),

            // Confidence indicator (subtle)
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: recommendation.confidence,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(recommendation.confidence * 100).toStringAsFixed(0)}% match',
                  key: Key('recommendation_${recommendation.id}_confidence'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
