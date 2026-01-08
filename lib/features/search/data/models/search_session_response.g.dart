// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchSessionResponse _$SearchSessionResponseFromJson(
  Map<String, dynamic> json,
) => SearchSessionResponse(
  id: json['id'] as String,
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => InteractionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map(
        (e) => RecommendationWithStatusResponse.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SearchSessionResponseToJson(
  SearchSessionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'interactions': instance.interactions,
  'recommendations': instance.recommendations,
  'created_at': instance.createdAt.toIso8601String(),
};
