import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/search/data/models/recommendation_with_status_response.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';

void main() {
  group('RecommendationWithStatusResponse', () {
    test('fromJson creates instance from JSON', () {
      final json = {
        'id': 'rec-123',
        'title': 'The Matrix',
        'description':
            'A computer hacker learns about the true nature of reality',
        'release_year': 1999,
        'rating': 8.7,
        'confidence': 0.92,
        'platforms': [
          {
            'name': 'Netflix',
            'slug': 'netflix',
            'url': 'https://netflix.com/watch/123',
            'is_preferred': true,
          },
        ],
        'status': 'proposed',
        'interaction_count': 5,
        'user_feedback': null,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': null,
      };

      final response = RecommendationWithStatusResponse.fromJson(json);

      expect(response.id, 'rec-123');
      expect(response.title, 'The Matrix');
      expect(response.releaseYear, 1999);
      expect(response.rating, 8.7);
      expect(response.confidence, 0.92);
      expect(response.status, 'proposed');
      expect(response.interactionCount, 5);
      expect(response.platforms.length, 1);
    });

    test('toEntity converts to domain entity with proposed status', () {
      final response = RecommendationWithStatusResponse(
        id: 'rec-456',
        title: 'Inception',
        confidence: 0.88,
        platforms: [
          PlatformResponse(
            name: 'Netflix',
            slug: 'netflix',
            url: 'https://netflix.com',
            isPreferred: true,
          ),
        ],
        status: 'proposed',
        interactionCount: 3,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final entity = response.toEntity();

      expect(entity, isA<RecommendationWithStatus>());
      expect(entity.title, 'Inception');
      expect(entity.status, RecommendationStatus.proposed);
      expect(entity.interactionCount, 3);
    });

    test('toEntity converts will_watch status correctly', () {
      final response = RecommendationWithStatusResponse(
        id: 'rec-789',
        title: 'The Dark Knight',
        confidence: 0.95,
        platforms: [
          PlatformResponse(
            name: 'HBO Max',
            slug: 'hbo',
            url: 'https://hbomax.com',
            isPreferred: false,
          ),
        ],
        status: 'will_watch',
        interactionCount: 1,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final entity = response.toEntity();

      expect(entity.status, RecommendationStatus.willWatch);
    });

    test('toEntity converts seen status correctly', () {
      final response = RecommendationWithStatusResponse(
        id: 'rec-101',
        title: 'Interstellar',
        confidence: 0.90,
        platforms: [],
        status: 'seen',
        interactionCount: 2,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final entity = response.toEntity();

      expect(entity.status, RecommendationStatus.seen);
    });

    test('toEntity converts declined status correctly', () {
      final response = RecommendationWithStatusResponse(
        id: 'rec-102',
        title: 'Some Movie',
        confidence: 0.75,
        platforms: [],
        status: 'declined',
        interactionCount: 1,
        userFeedback: 'Not interested',
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final entity = response.toEntity();

      expect(entity.status, RecommendationStatus.declined);
      expect(entity.userFeedback, 'Not interested');
    });

    test('toEntity handles invalid status as proposed', () {
      final response = RecommendationWithStatusResponse(
        id: 'rec-103',
        title: 'Test Movie',
        confidence: 0.80,
        platforms: [],
        status: 'invalid_status',
        interactionCount: 1,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final entity = response.toEntity();

      expect(entity.status, RecommendationStatus.proposed);
    });
  });
}
