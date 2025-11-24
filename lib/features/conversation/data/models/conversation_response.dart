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

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class MessageResponse {
  final String id;
  final String content;
  final DateTime timestamp;
  final String author;
  final String type;
  final RecommendationResponse? recommendation;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  MessageResponse({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
    required this.type,
    this.recommendation,
  });

  Message toMessage() =>
      Message(id: id, content: content, timestamp: timestamp, author: author);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class RecommendationResponse {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'release_year')
  final int? releaseYear;
  final double? rating;
  final double confidence;
  final List<PlatformResponse> platforms;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseFromJson(json);

  RecommendationResponse({
    required this.id,
    required this.title,
    this.description,
    this.releaseYear,
    this.rating,
    required this.confidence,
    required this.platforms,
  });

  Map<String, dynamic> toJson() => _$RecommendationResponseToJson(this);
}

@JsonSerializable()
class PlatformResponse {
  final String name;
  final String slug;
  final String url;
  @JsonKey(name: 'is_preferred')
  final bool isPreferred;

  factory PlatformResponse.fromJson(Map<String, dynamic> json) =>
      _$PlatformResponseFromJson(json);

  PlatformResponse({
    required this.name,
    required this.slug,
    required this.url,
    required this.isPreferred,
  });

  Map<String, dynamic> toJson() => _$PlatformResponseToJson(this);
}
