import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/search/domain/entities/search_session_summary.dart';

part 'search_session_summary_dto.g.dart';

@JsonSerializable()
class SearchSessionSummaryDto {
  final String id;
  @JsonKey(name: 'initial_message')
  final String? initialMessage;
  @JsonKey(name: 'preview_text')
  final String previewText;
  @JsonKey(name: 'interaction_count')
  final int interactionCount;
  @JsonKey(name: 'recommendation_count')
  final int recommendationCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SearchSessionSummaryDto({
    required this.id,
    this.initialMessage,
    required this.previewText,
    required this.interactionCount,
    required this.recommendationCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SearchSessionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SearchSessionSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchSessionSummaryDtoToJson(this);

  SearchSessionSummary toEntity() {
    return SearchSessionSummary(
      id: id,
      initialMessage: initialMessage,
      previewText: previewText,
      interactionCount: interactionCount,
      recommendationCount: recommendationCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class SearchSessionListResponseDto {
  final List<SearchSessionSummaryDto> sessions;
  final int total;

  SearchSessionListResponseDto({required this.sessions, required this.total});

  factory SearchSessionListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchSessionListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchSessionListResponseDtoToJson(this);
}
