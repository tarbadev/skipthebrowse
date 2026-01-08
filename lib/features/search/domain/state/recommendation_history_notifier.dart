import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    extends StateNotifier<AsyncValue<RecommendationHistoryState>> {
  final SearchRepository repository;

  RecommendationHistoryNotifier(this.repository)
    : super(
        const AsyncValue.data(RecommendationHistoryState(recommendations: [])),
      );

  Future<void> loadHistory({
    RecommendationStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    state = const AsyncLoading<RecommendationHistoryState>().copyWithPrevious(
      state,
    );
    try {
      final recommendations = await repository.getRecommendationHistory(
        status: status,
        limit: limit,
        offset: offset,
      );
      state = AsyncValue.data(
        RecommendationHistoryState(
          recommendations: recommendations,
          currentFilter: status,
          searchQuery: null,
        ),
      );
    } catch (err, stack) {
      state = AsyncError<RecommendationHistoryState>(
        err,
        stack,
      ).copyWithPrevious(state);
    }
  }

  Future<void> search(String query, {int limit = 50}) async {
    if (query.isEmpty) {
      // Reload history when search is cleared
      await loadHistory();
      return;
    }

    state = const AsyncLoading<RecommendationHistoryState>().copyWithPrevious(
      state,
    );
    try {
      final recommendations = await repository.searchRecommendations(
        query,
        limit: limit,
      );
      state = AsyncValue.data(
        RecommendationHistoryState(
          recommendations: recommendations,
          currentFilter: null,
          searchQuery: query,
        ),
      );
    } catch (err, stack) {
      state = AsyncError<RecommendationHistoryState>(
        err,
        stack,
      ).copyWithPrevious(state);
    }
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

    state = AsyncValue.data(
      currentState.copyWith(recommendations: updatedRecommendations),
    );

    try {
      await repository.updateRecommendationStatus(
        recommendationId,
        newStatus,
        feedback: feedback,
      );
    } catch (err, stack) {
      // Revert on error
      state = AsyncError<RecommendationHistoryState>(
        err,
        stack,
      ).copyWithPrevious(AsyncValue.data(currentState));
    }
  }

  void clear() {
    state = const AsyncValue.data(
      RecommendationHistoryState(recommendations: []),
    );
  }
}
