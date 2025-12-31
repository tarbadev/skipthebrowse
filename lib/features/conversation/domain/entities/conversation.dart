import 'package:equatable/equatable.dart';
import 'message.dart';

class Conversation extends Equatable {
  final String id;
  final List<Message> messages;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.messages,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, messages, createdAt];
}

class ConversationSummary extends Equatable {
  final String id;
  final String status;
  final String previewText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final int recommendationCount;

  const ConversationSummary({
    required this.id,
    required this.status,
    required this.previewText,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.recommendationCount,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    previewText,
    createdAt,
    updatedAt,
    messageCount,
    recommendationCount,
  ];
}
