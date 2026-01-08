import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/data/models/search_session_response.dart';
import 'package:skipthebrowse/features/search/data/models/create_search_session_request.dart';
import 'package:skipthebrowse/features/search/data/models/add_interaction_request.dart';
import 'package:skipthebrowse/features/search/data/models/update_recommendation_status_request.dart';
import 'package:skipthebrowse/features/search/data/models/recommendation_with_status_response.dart';

part 'search_rest_client.g.dart';

@RestApi()
abstract class SearchRestClient {
  factory SearchRestClient(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _SearchRestClient;

  @POST('/api/v1/search-sessions')
  Future<SearchSessionResponse> createSearchSession(
    @Body() CreateSearchSessionRequest request,
  );

  @POST('/api/v1/search-sessions/{id}/interact')
  Future<SearchSessionResponse> addInteraction(
    @Path('id') String sessionId,
    @Body() AddInteractionRequest request,
  );

  @GET('/api/v1/search-sessions/{id}')
  Future<SearchSessionResponse> getSearchSession(@Path('id') String sessionId);

  @PATCH('/api/v1/recommendations/{id}/status')
  Future<void> updateRecommendationStatus(
    @Path('id') String recommendationId,
    @Body() UpdateRecommendationStatusRequest request,
  );

  @GET('/api/v1/recommendations/history')
  Future<RecommendationHistoryResponse> getRecommendationHistory(
    @Query('status') String? status,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/api/v1/recommendations/search')
  Future<SearchRecommendationsResponse> searchRecommendations(
    @Query('q') String query,
    @Query('limit') int limit,
  );
}

@JsonSerializable()
class RecommendationHistoryResponse {
  final List<RecommendationWithStatusResponse> recommendations;
  final int total;
  final int limit;
  final int offset;

  RecommendationHistoryResponse({
    required this.recommendations,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory RecommendationHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationHistoryResponseToJson(this);
}

@JsonSerializable()
class SearchRecommendationsResponse {
  final List<RecommendationWithStatusResponse> recommendations;

  SearchRecommendationsResponse({required this.recommendations});

  factory SearchRecommendationsResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchRecommendationsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchRecommendationsResponseToJson(this);
}
