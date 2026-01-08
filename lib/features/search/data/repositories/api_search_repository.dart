import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';
import 'package:skipthebrowse/features/search/domain/repositories/search_repository.dart';
import 'package:skipthebrowse/features/search/data/repositories/search_rest_client.dart';
import 'package:skipthebrowse/features/search/data/models/create_search_session_request.dart';
import 'package:skipthebrowse/features/search/data/models/add_interaction_request.dart';
import 'package:skipthebrowse/features/search/data/models/update_recommendation_status_request.dart';

class ApiSearchRepository implements SearchRepository {
  final SearchRestClient restClient;

  ApiSearchRepository({required this.restClient});

  @override
  Future<SearchSession> createSearchSession(
    String message, {
    String region = 'US',
  }) async {
    final request = CreateSearchSessionRequest(
      message: message,
      region: region,
    );

    final response = await restClient.createSearchSession(request);
    return response.toEntity();
  }

  @override
  Future<SearchSession> addInteraction(
    String sessionId,
    String choiceId, {
    String? customInput,
  }) async {
    final request = AddInteractionRequest(
      choiceId: choiceId,
      customInput: customInput,
    );

    final response = await restClient.addInteraction(sessionId, request);
    return response.toEntity();
  }

  @override
  Future<SearchSession> getSearchSession(String sessionId) async {
    final response = await restClient.getSearchSession(sessionId);
    return response.toEntity();
  }

  @override
  Future<void> updateRecommendationStatus(
    String recommendationId,
    RecommendationStatus status, {
    String? feedback,
  }) async {
    final request = UpdateRecommendationStatusRequest(
      status: _statusToString(status),
      feedback: feedback,
    );

    await restClient.updateRecommendationStatus(recommendationId, request);
  }

  @override
  Future<List<RecommendationWithStatus>> getRecommendationHistory({
    RecommendationStatus? status,
    int limit = 100,
    int offset = 0,
  }) async {
    final statusString = status != null ? _statusToString(status) : null;

    final response = await restClient.getRecommendationHistory(
      statusString,
      limit,
      offset,
    );

    return response.recommendations.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<RecommendationWithStatus>> searchRecommendations(
    String query, {
    int limit = 50,
  }) async {
    final response = await restClient.searchRecommendations(query, limit);
    return response.recommendations.map((r) => r.toEntity()).toList();
  }

  String _statusToString(RecommendationStatus status) {
    switch (status) {
      case RecommendationStatus.proposed:
        return 'proposed';
      case RecommendationStatus.seen:
        return 'seen';
      case RecommendationStatus.willWatch:
        return 'will_watch';
      case RecommendationStatus.declined:
        return 'declined';
    }
  }
}
