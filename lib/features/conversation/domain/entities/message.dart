import 'package:equatable/equatable.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';

enum MessageType { recommendation, question }

enum MessageStatus { sent, pending, failed }

class Message extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final String author;
  final MessageType type;
  final Recommendation? recommendation;
  final List<String>? quickReplies;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
    required this.type,
    this.recommendation,
    this.quickReplies,
    this.status = MessageStatus.sent,
  });

  Message copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    String? author,
    MessageType? type,
    Recommendation? recommendation,
    List<String>? quickReplies,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      type: type ?? this.type,
      recommendation: recommendation ?? this.recommendation,
      quickReplies: quickReplies ?? this.quickReplies,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    timestamp,
    author,
    type,
    recommendation,
    quickReplies,
    status,
  ];
}
