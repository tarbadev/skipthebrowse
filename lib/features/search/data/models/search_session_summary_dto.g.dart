// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_session_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchSessionSummaryDto _$SearchSessionSummaryDtoFromJson(
  Map<String, dynamic> json,
) => SearchSessionSummaryDto(
  id: json['id'] as String,
  initialMessage: json['initial_message'] as String?,
  previewText: json['preview_text'] as String,
  interactionCount: (json['interaction_count'] as num).toInt(),
  recommendationCount: (json['recommendation_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SearchSessionSummaryDtoToJson(
  SearchSessionSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'initial_message': instance.initialMessage,
  'preview_text': instance.previewText,
  'interaction_count': instance.interactionCount,
  'recommendation_count': instance.recommendationCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

SearchSessionListResponseDto _$SearchSessionListResponseDtoFromJson(
  Map<String, dynamic> json,
) => SearchSessionListResponseDto(
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => SearchSessionSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$SearchSessionListResponseDtoToJson(
  SearchSessionListResponseDto instance,
) => <String, dynamic>{'sessions': instance.sessions, 'total': instance.total};
