// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultResponse _$SearchResultResponseFromJson(
  Map<String, dynamic> json,
) => SearchResultResponse(
  conversation: ConversationSummaryResponse.fromJson(
    json['conversation'] as Map<String, dynamic>,
  ),
  matchedContent: json['matched_content'] as String,
  rank: (json['rank'] as num).toDouble(),
);

Map<String, dynamic> _$SearchResultResponseToJson(
  SearchResultResponse instance,
) => <String, dynamic>{
  'conversation': instance.conversation,
  'matched_content': instance.matchedContent,
  'rank': instance.rank,
};

ConversationSearchResponse _$ConversationSearchResponseFromJson(
  Map<String, dynamic> json,
) => ConversationSearchResponse(
  results: (json['results'] as List<dynamic>)
      .map((e) => SearchResultResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  query: json['query'] as String,
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
);

Map<String, dynamic> _$ConversationSearchResponseToJson(
  ConversationSearchResponse instance,
) => <String, dynamic>{
  'results': instance.results,
  'total': instance.total,
  'query': instance.query,
  'limit': instance.limit,
  'offset': instance.offset,
};
