import 'package:json_annotation/json_annotation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

part 'conversation_response.g.dart';

@JsonSerializable()
class ConversationResponse {
  final String id;
  final List<MessageResponse> messages;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  ConversationResponse({
    required this.id,
    required this.messages,
    required this.createdAt,
  });

  Conversation toConversation() => Conversation(
    id: id,
    messages: messages.map((m) => m.toMessage()).toList(),
    createdAt: createdAt,
  );
}

@JsonSerializable()
class MessageResponse {
  final String id;
  final String content;
  final DateTime timestamp;
  final String author;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  MessageResponse({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
  });

  Message toMessage() =>
      Message(id: id, content: content, timestamp: timestamp, author: author);
}
