import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';
import 'package:skipthebrowse/features/search/domain/state/recommendation_history_notifier.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;
  late RecommendationHistoryNotifier notifier;

  setUp(() {
    mockRepository = MockSearchRepository();
    notifier = RecommendationHistoryNotifier(mockRepository);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('RecommendationHistoryNotifier', () {
    test('initial state has empty recommendations', () {
      expect(notifier.state.value?.recommendations, isEmpty);
    });

    test('loadHistory updates state with recommendations', () async {
      final mockRecs = [
        RecommendationWithStatus(
          id: 'rec-1',
          title: 'Test Movie',
          confidence: 0.9,
          platforms: const [
            Platform(
              name: 'Netflix',
              slug: 'netflix',
              url: 'https://netflix.com',
              isPreferred: true,
            ),
          ],
          status: RecommendationStatus.proposed,
          interactionCount: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(
        () => mockRepository.getRecommendationHistory(
          status: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => mockRecs);

      await notifier.loadHistory();

      expect(notifier.state.value?.recommendations, mockRecs);
      expect(notifier.state.value?.currentFilter, isNull);
    });

    test('loadHistory with status filter', () async {
      final mockRecs = <RecommendationWithStatus>[];

      when(
        () => mockRepository.getRecommendationHistory(
          status: RecommendationStatus.willWatch,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => mockRecs);

      await notifier.loadHistory(status: RecommendationStatus.willWatch);

      expect(
        notifier.state.value?.currentFilter,
        RecommendationStatus.willWatch,
      );
      verify(
        () => mockRepository.getRecommendationHistory(
          status: RecommendationStatus.willWatch,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });

    test('search updates state with search results', () async {
      final mockRecs = [
        RecommendationWithStatus(
          id: 'rec-1',
          title: 'Dark Knight',
          confidence: 0.95,
          platforms: const [],
          status: RecommendationStatus.proposed,
          interactionCount: 1,
          createdAt: DateTime.now(),
        ),
      ];

      when(
        () => mockRepository.searchRecommendations('dark', limit: 50),
      ).thenAnswer((_) async => mockRecs);

      await notifier.search('dark');

      expect(notifier.state.value?.recommendations, mockRecs);
      expect(notifier.state.value?.searchQuery, 'dark');
    });

    test('search with empty query reloads history', () async {
      final mockRecs = <RecommendationWithStatus>[];

      when(
        () => mockRepository.getRecommendationHistory(
          status: null,
          limit: 100,
          offset: 0,
        ),
      ).thenAnswer((_) async => mockRecs);

      await notifier.search('');

      expect(notifier.state.value?.searchQuery, isNull);
      verify(
        () => mockRepository.getRecommendationHistory(
          status: null,
          limit: 100,
          offset: 0,
        ),
      ).called(1);
    });

    test('updateStatus performs optimistic update', () async {
      final rec = RecommendationWithStatus(
        id: 'rec-1',
        title: 'Test Movie',
        confidence: 0.9,
        platforms: const [],
        status: RecommendationStatus.proposed,
        interactionCount: 1,
        createdAt: DateTime.now(),
      );

      notifier.state = AsyncData(
        RecommendationHistoryState(recommendations: [rec]),
      );

      when(
        () => mockRepository.updateRecommendationStatus(
          'rec-1',
          RecommendationStatus.willWatch,
        ),
      ).thenAnswer((_) async => {});

      await notifier.updateStatus('rec-1', RecommendationStatus.willWatch);

      expect(
        notifier.state.value?.recommendations[0].status,
        RecommendationStatus.willWatch,
      );
    });

    test('updateStatus reverts on error', () async {
      final rec = RecommendationWithStatus(
        id: 'rec-1',
        title: 'Test Movie',
        confidence: 0.9,
        platforms: const [],
        status: RecommendationStatus.proposed,
        interactionCount: 1,
        createdAt: DateTime.now(),
      );

      final initialState = RecommendationHistoryState(recommendations: [rec]);
      notifier.state = AsyncData(initialState);

      when(
        () => mockRepository.updateRecommendationStatus(
          'rec-1',
          RecommendationStatus.willWatch,
        ),
      ).thenThrow(Exception('API Error'));

      await notifier.updateStatus('rec-1', RecommendationStatus.willWatch);

      // Should have error but preserve previous state
      expect(notifier.state, isA<AsyncError<RecommendationHistoryState>>());
    });

    test('clear resets state', () async {
      final mockRecs = [
        RecommendationWithStatus(
          id: 'rec-1',
          title: 'Test',
          confidence: 0.9,
          platforms: const [],
          status: RecommendationStatus.proposed,
          interactionCount: 1,
          createdAt: DateTime.now(),
        ),
      ];

      notifier.state = AsyncData(
        RecommendationHistoryState(recommendations: mockRecs),
      );

      notifier.clear();

      expect(notifier.state.value?.recommendations, isEmpty);
    });
  });
}
