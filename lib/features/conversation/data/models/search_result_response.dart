import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/search_result.dart';
import 'conversation_list_response.dart';

part 'search_result_response.g.dart';

@JsonSerializable()
class SearchResultResponse {
  final ConversationSummaryResponse conversation;
  @JsonKey(name: 'matched_content')
  final String matchedContent;
  final double rank;

  SearchResultResponse({
    required this.conversation,
    required this.matchedContent,
    required this.rank,
  });

  factory SearchResultResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultResponseToJson(this);

  SearchResult toSearchResult() {
    return SearchResult(
      summary: conversation.toConversationSummary(),
      matchedContent: matchedContent,
      rank: rank,
    );
  }
}

@JsonSerializable()
class ConversationSearchResponse {
  final List<SearchResultResponse> results;
  final int total;
  final String query;
  final int limit;
  final int offset;

  ConversationSearchResponse({
    required this.results,
    required this.total,
    required this.query,
    required this.limit,
    required this.offset,
  });

  factory ConversationSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSearchResponseToJson(this);

  ConversationSearchResults toConversationSearchResults() {
    return ConversationSearchResults(
      results: results.map((r) => r.toSearchResult()).toList(),
      total: total,
      query: query,
    );
  }
}
