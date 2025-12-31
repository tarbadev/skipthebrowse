// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationSummaryResponse _$ConversationSummaryResponseFromJson(
  Map<String, dynamic> json,
) => ConversationSummaryResponse(
  id: json['id'] as String,
  status: json['status'] as String,
  previewText: json['preview_text'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  messageCount: (json['message_count'] as num).toInt(),
  recommendationCount: (json['recommendation_count'] as num).toInt(),
);

Map<String, dynamic> _$ConversationSummaryResponseToJson(
  ConversationSummaryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'preview_text': instance.previewText,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'message_count': instance.messageCount,
  'recommendation_count': instance.recommendationCount,
};

ConversationListResponse _$ConversationListResponseFromJson(
  Map<String, dynamic> json,
) => ConversationListResponse(
  conversations: (json['conversations'] as List<dynamic>)
      .map(
        (e) => ConversationSummaryResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  total: (json['total'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
);

Map<String, dynamic> _$ConversationListResponseToJson(
  ConversationListResponse instance,
) => <String, dynamic>{
  'conversations': instance.conversations,
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
};
