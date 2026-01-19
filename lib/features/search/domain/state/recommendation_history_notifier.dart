import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/state/base_async_notifier.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';

class RecommendationHistoryState {
  final List<RecommendationWithStatus> recommendations;
  final RecommendationStatus? currentFilter;
  final String? searchQuery;

  const RecommendationHistoryState({
    required this.recommendations,
    this.currentFilter,
    this.searchQuery,
  });

  RecommendationHistoryState copyWith({
    List<RecommendationWithStatus>? recommendations,
    RecommendationStatus? currentFilter,
    String? searchQuery,
  }) {
    return RecommendationHistoryState(
      recommendations: recommendations ?? this.recommendations,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RecommendationHistoryNotifier
    extends BaseAsyncNotifier<RecommendationHistoryState> {
  final SearchRepository repository;

  RecommendationHistoryNotifier(this.repository)
    : super(
        const AsyncValue.data(RecommendationHistoryState(recommendations: [])),
      );

  Future<void> loadHistory({
    RecommendationStatus? status,
    int limit = 100,
    int offset = 0,
  }) => executeWithTransform(
    operation: () => repository.getRecommendationHistory(
      status: status,
      limit: limit,
      offset: offset,
    ),
    transform: (recommendations) => RecommendationHistoryState(
      recommendations: recommendations,
      currentFilter: status,
      searchQuery: null,
    ),
    keepPrevious: true,
  );

  Future<void> search(String query, {int limit = 50}) async {
    if (query.isEmpty) {
      // Reload history when search is cleared
      await loadHistory();
      return;
    }

    await executeWithTransform(
      operation: () => repository.searchRecommendations(query, limit: limit),
      transform: (recommendations) => RecommendationHistoryState(
        recommendations: recommendations,
        currentFilter: null,
        searchQuery: query,
      ),
      keepPrevious: true,
    );
  }

  Future<void> updateStatus(
    String recommendationId,
    RecommendationStatus newStatus, {
    String? feedback,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    final updatedRecommendations = currentState.recommendations.map((rec) {
      if (rec.id == recommendationId) {
        return RecommendationWithStatus(
          id: rec.id,
          title: rec.title,
          description: rec.description,
          releaseYear: rec.releaseYear,
          rating: rec.rating,
          confidence: rec.confidence,
          platforms: rec.platforms,
          status: newStatus,
          interactionCount: rec.interactionCount,
          userFeedback: feedback ?? rec.userFeedback,
          createdAt: rec.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return rec;
    }).toList();

    await executeWithOptimisticUpdate(
      optimisticState: currentState.copyWith(
        recommendations: updatedRecommendations,
      ),
      operation: () => repository.updateRecommendationStatus(
        recommendationId,
        newStatus,
        feedback: feedback,
      ),
    );
  }

  void clear() {
    state = const AsyncValue.data(
      RecommendationHistoryState(recommendations: []),
    );
  }
}
