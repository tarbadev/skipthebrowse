import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';

abstract class SearchRepository {
  Future<SearchSession> createSearchSession(
    String message, {
    String region = 'US',
  });

  Future<SearchSession> addInteraction(
    String sessionId,
    String choiceId, {
    String? customInput,
  });

  Future<SearchSession> getSearchSession(String sessionId);

  Future<void> updateRecommendationStatus(
    String recommendationId,
    RecommendationStatus status, {
    String? feedback,
  });

  Future<List<RecommendationWithStatus>> getRecommendationHistory({
    RecommendationStatus? status,
    int limit = 100,
    int offset = 0,
  });

  Future<List<RecommendationWithStatus>> searchRecommendations(
    String query, {
    int limit = 50,
  });
}
