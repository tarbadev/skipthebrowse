import 'package:equatable/equatable.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';

enum MessageType { recommendation, question }

class Message extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final String author;
  final MessageType type;
  final Recommendation? recommendation;

  const Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
    required this.type,
    this.recommendation,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    timestamp,
    author,
    type,
    recommendation,
  ];
}
