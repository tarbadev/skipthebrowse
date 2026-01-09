import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session.dart';
import 'interaction_response.dart';
import 'recommendation_with_status_response.dart';

part 'search_session_response.g.dart';

@JsonSerializable()
class SearchSessionResponse {
  final String id;
  @JsonKey(name: 'initial_message')
  final String? initialMessage;
  final List<InteractionResponse> interactions;
  final List<RecommendationWithStatusResponse> recommendations;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory SearchSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchSessionResponseFromJson(json);

  SearchSessionResponse({
    required this.id,
    this.initialMessage,
    required this.interactions,
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => _$SearchSessionResponseToJson(this);

  SearchSession toEntity() => SearchSession(
    id: id,
    initialMessage: initialMessage,
    interactions: interactions.map((i) => i.toEntity()).toList(),
    recommendations: recommendations.map((r) => r.toEntity()).toList(),
    createdAt: createdAt,
  );
}
