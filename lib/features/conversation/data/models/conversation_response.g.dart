// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationResponse _$ConversationResponseFromJson(
  Map<String, dynamic> json,
) => ConversationResponse(
  id: json['id'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ConversationResponseToJson(
  ConversationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'messages': instance.messages,
  'created_at': instance.createdAt.toIso8601String(),
};

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      author: json['author'] as String,
      type: json['type'] as String,
      recommendation: json['recommendation'] == null
          ? null
          : RecommendationResponse.fromJson(
              json['recommendation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'author': instance.author,
      'type': instance.type,
      'recommendation': instance.recommendation,
    };

RecommendationResponse _$RecommendationResponseFromJson(
  Map<String, dynamic> json,
) => RecommendationResponse(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  releaseYear: (json['release_year'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  platforms: (json['platforms'] as List<dynamic>)
      .map((e) => PlatformResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecommendationResponseToJson(
  RecommendationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'release_year': instance.releaseYear,
  'rating': instance.rating,
  'confidence': instance.confidence,
  'platforms': instance.platforms,
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
