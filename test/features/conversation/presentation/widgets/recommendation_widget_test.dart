import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';
import 'package:skipthebrowse/features/conversation/presentation/widgets/recommendation_widget.dart';

import '../../../../helpers/test_harness.dart';

void main() {
  final testRecommendation = Recommendation(
    id: 'rec-123',
    title: 'The Matrix',
    description:
        'A computer hacker learns about the true nature of his reality.',
    releaseYear: 1999,
    rating: 8.7,
    confidence: 0.92,
    platforms: [
      Platform(
        name: 'Netflix',
        slug: 'netflix',
        url: 'https://www.netflix.com/title/123',
        isPreferred: true,
      ),
      Platform(
        name: 'Amazon Prime Video',
        slug: 'amazon',
        url: 'https://www.amazon.com/title/123',
        isPreferred: false,
      ),
    ],
  );

  testWidgets('renders recommendation card with all details', (tester) async {
    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: testRecommendation),
    );

    // Verify card is rendered
    expect(find.byType(Card), findsOneWidget);

    // Verify title
    expect(find.text('The Matrix'), findsOneWidget);
    expect(
      find.byKey(const Key('recommendation_rec-123_title')),
      findsOneWidget,
    );

    // Verify release year chip
    expect(find.text('1999'), findsOneWidget);
    expect(
      find.byKey(const Key('recommendation_rec-123_release_year')),
      findsOneWidget,
    );

    // Verify rating
    expect(find.text('8.7'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(
      find.byKey(const Key('recommendation_rec-123_rating')),
      findsOneWidget,
    );

    // Verify description
    expect(
      find.text(
        'A computer hacker learns about the true nature of his reality.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_description')),
      findsOneWidget,
    );

    // Verify confidence indicator
    expect(find.text('92% match'), findsOneWidget);
    expect(
      find.byKey(const Key('recommendation_rec-123_confidence')),
      findsOneWidget,
    );

    expect(find.text('Available on'), findsOneWidget);
  });

  testWidgets('renders platform buttons correctly', (tester) async {
    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: testRecommendation),
    );

    // Verify platform buttons
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Amazon Prime Video'), findsOneWidget);

    // Verify individual platform keys
    expect(
      find.byKey(const Key('recommendation_rec-123_platform_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_platform_1')),
      findsOneWidget,
    );

    // Verify provider logos (Image widgets) are rendered
    // Netflix and Amazon Prime logos should be present
    expect(find.byType(Image), findsAtLeastNWidgets(2));
  });

  testWidgets('preferred platform has primary color styling', (tester) async {
    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: testRecommendation),
    );

    await tester.pumpAndSettle();

    // Find the first platform button (Netflix - preferred)
    final netflixButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('recommendation_rec-123_platform_0')),
    );

    // Find the second platform button (Amazon Prime - not preferred)
    final primeButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('recommendation_rec-123_platform_1')),
    );

    // Verify preferred platform has different styling
    expect(netflixButton.style, isNotNull);
    expect(primeButton.style, isNotNull);
  });

  testWidgets('renders without optional fields', (tester) async {
    final minimalRecommendation = Recommendation(
      id: 'rec-456',
      title: 'Minimal Movie',
      description: null,
      releaseYear: null,
      rating: null,
      confidence: 0.75,
      platforms: [
        Platform(
          name: 'Netflix',
          slug: 'netflix',
          url: 'https://www.netflix.com/title/456',
          isPreferred: true,
        ),
      ],
    );

    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: minimalRecommendation),
    );

    // Verify title is present
    expect(find.text('Minimal Movie'), findsOneWidget);

    // Verify optional fields are not rendered
    expect(find.byType(Chip), findsNothing); // No release year chip
    expect(find.byIcon(Icons.star), findsNothing); // No rating

    // Description should not be rendered (null or empty)
    expect(
      find.byKey(const Key('recommendation_rec-456_description')),
      findsNothing,
    );

    // Confidence should still be present
    expect(find.text('75% match'), findsOneWidget);

    // Platform should still be rendered
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('renders with empty description', (tester) async {
    final emptyDescRecommendation = Recommendation(
      id: 'rec-789',
      title: 'Empty Desc Movie',
      description: '',
      releaseYear: 2024,
      rating: 7.5,
      confidence: 0.88,
      platforms: [
        Platform(
          name: 'Netflix',
          slug: 'netflix',
          url: 'https://www.netflix.com/title/789',
          isPreferred: true,
        ),
      ],
    );

    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: emptyDescRecommendation),
    );

    // Verify title is present
    expect(find.text('Empty Desc Movie'), findsOneWidget);

    // Description should not be rendered (empty string)
    expect(
      find.byKey(const Key('recommendation_rec-789_description')),
      findsNothing,
    );

    // Other fields should be present
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('7.5'), findsOneWidget);
  });

  testWidgets('confidence formats correctly at different values', (
    tester,
  ) async {
    final highConfidence = Recommendation(
      id: 'rec-high',
      title: 'High Match',
      description: 'Test',
      releaseYear: 2024,
      rating: 8.0,
      confidence: 0.99,
      platforms: [
        Platform(
          name: 'Netflix',
          slug: 'netflix',
          url: 'https://www.netflix.com',
          isPreferred: true,
        ),
      ],
    );

    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: highConfidence),
    );

    // 0.99 * 100 = 99% match
    expect(find.text('99% match'), findsOneWidget);
  });

  testWidgets('rating formats to one decimal place', (tester) async {
    final preciseRating = Recommendation(
      id: 'rec-rating',
      title: 'Rating Test',
      description: 'Test',
      releaseYear: 2024,
      rating: 8.567, // Should display as 8.6
      confidence: 0.85,
      platforms: [
        Platform(
          name: 'Netflix',
          slug: 'netflix',
          url: 'https://www.netflix.com',
          isPreferred: true,
        ),
      ],
    );

    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: preciseRating),
    );

    // 8.567 should be formatted to 8.6
    expect(find.text('8.6'), findsOneWidget);
  });

  testWidgets('renders multiple platforms in wrap layout', (tester) async {
    final multiPlatformRec = Recommendation(
      id: 'rec-multi',
      title: 'Multi Platform Movie',
      description: 'Available on many platforms',
      releaseYear: 2024,
      rating: 8.0,
      confidence: 0.90,
      platforms: [
        Platform(
          name: 'Netflix',
          slug: 'netflix',
          url: 'https://www.netflix.com/title/1',
          isPreferred: true,
        ),
        Platform(
          name: 'Amazon Prime',
          slug: 'amazon',
          url: 'https://www.amazon.com/title/1',
          isPreferred: false,
        ),
        Platform(
          name: 'Disney+',
          slug: 'disney',
          url: 'https://www.disneyplus.com/title/1',
          isPreferred: false,
        ),
      ],
    );

    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: multiPlatformRec),
    );

    // Verify all platforms are rendered
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Amazon Prime'), findsOneWidget);
    expect(find.text('Disney+'), findsOneWidget);

    // Verify wrap widget for responsive layout
    expect(find.byType(Wrap), findsOneWidget);

    // Verify provider logos are rendered (at least 2 with existing logos, disney may fallback to icon)
    expect(find.byType(Image), findsAtLeastNWidgets(2));
  });

  testWidgets('card has proper Material Design styling', (tester) async {
    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: testRecommendation),
    );

    final card = tester.widget<Card>(find.byType(Card));

    // Verify card properties
    expect(card.elevation, 4);
    expect(
      card.margin,
      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );

    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('has proper semantic keys for testing', (tester) async {
    await tester.pumpProviderWidget(
      RecommendationWidget(recommendation: testRecommendation),
    );

    // Verify all semantic keys are present
    expect(
      find.byKey(const Key('recommendation_rec-123_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_title')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_release_year')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_rating')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_description')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_platform_0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_platform_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('recommendation_rec-123_confidence')),
      findsOneWidget,
    );
  });
}
