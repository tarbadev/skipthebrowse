import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/conversation.dart';

part 'conversation_list_response.g.dart';

@JsonSerializable()
class ConversationSummaryResponse {
  final String id;
  final String status;
  @JsonKey(name: 'preview_text')
  final String previewText;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'message_count')
  final int messageCount;

  ConversationSummaryResponse({
    required this.id,
    required this.status,
    required this.previewText,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ConversationSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSummaryResponseToJson(this);

  ConversationSummary toConversationSummary() {
    return ConversationSummary(
      id: id,
      status: status,
      previewText: previewText,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageCount: messageCount,
    );
  }
}

@JsonSerializable()
class ConversationListResponse {
  final List<ConversationSummaryResponse> conversations;
  final int total;
  final int limit;
  final int offset;

  ConversationListResponse({
    required this.conversations,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationListResponseToJson(this);
}
