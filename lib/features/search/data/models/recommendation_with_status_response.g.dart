// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_with_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationWithStatusResponse _$RecommendationWithStatusResponseFromJson(
  Map<String, dynamic> json,
) => RecommendationWithStatusResponse(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  releaseYear: (json['release_year'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  platforms: (json['platforms'] as List<dynamic>)
      .map((e) => PlatformResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
  interactionCount: (json['interaction_count'] as num).toInt(),
  userFeedback: json['user_feedback'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RecommendationWithStatusResponseToJson(
  RecommendationWithStatusResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'release_year': instance.releaseYear,
  'rating': instance.rating,
  'confidence': instance.confidence,
  'platforms': instance.platforms,
  'status': instance.status,
  'interaction_count': instance.interactionCount,
  'user_feedback': instance.userFeedback,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

PlatformResponse _$PlatformResponseFromJson(Map<String, dynamic> json) =>
    PlatformResponse(
      name: json['name'] as String,
      slug: json['slug'] as String,
      url: json['url'] as String,
      isPreferred: json['is_preferred'] as bool,
    );

Map<String, dynamic> _$PlatformResponseToJson(PlatformResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'url': instance.url,
      'is_preferred': instance.isPreferred,
    };
