import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';
import 'package:skipthebrowse/features/search/domain/entities/recommendation_with_status.dart';

part 'recommendation_with_status_response.g.dart';

@JsonSerializable()
class RecommendationWithStatusResponse {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'release_year')
  final int? releaseYear;
  final double? rating;
  final double confidence;
  final List<PlatformResponse> platforms;
  final String status;
  @JsonKey(name: 'interaction_count')
  final int interactionCount;
  @JsonKey(name: 'user_feedback')
  final String? userFeedback;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory RecommendationWithStatusResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$RecommendationWithStatusResponseFromJson(json);

  RecommendationWithStatusResponse({
    required this.id,
    required this.title,
    this.description,
    this.releaseYear,
    this.rating,
    required this.confidence,
    required this.platforms,
    required this.status,
    required this.interactionCount,
    this.userFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() =>
      _$RecommendationWithStatusResponseToJson(this);

  RecommendationWithStatus toEntity() => RecommendationWithStatus(
    id: id,
    title: title,
    description: description,
    releaseYear: releaseYear,
    rating: rating,
    confidence: confidence,
    platforms: platforms.map((p) => p.toPlatform()).toList(),
    status: _parseStatus(status),
    interactionCount: interactionCount,
    userFeedback: userFeedback,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  RecommendationStatus _parseStatus(String status) {
    switch (status) {
      case 'proposed':
        return RecommendationStatus.proposed;
      case 'seen':
        return RecommendationStatus.seen;
      case 'will_watch':
        return RecommendationStatus.willWatch;
      case 'declined':
        return RecommendationStatus.declined;
      default:
        return RecommendationStatus.proposed;
    }
  }
}

@JsonSerializable()
class PlatformResponse {
  final String name;
  final String slug;
  final String url;
  @JsonKey(name: 'is_preferred')
  final bool isPreferred;

  factory PlatformResponse.fromJson(Map<String, dynamic> json) =>
      _$PlatformResponseFromJson(json);

  PlatformResponse({
    required this.name,
    required this.slug,
    required this.url,
    required this.isPreferred,
  });

  Map<String, dynamic> toJson() => _$PlatformResponseToJson(this);

  Platform toPlatform() =>
      Platform(name: name, slug: slug, url: url, isPreferred: isPreferred);
}
