import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;
  final String author;

  const Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.author,
  });

  @override
  List<Object?> get props => [id, content, timestamp, author];
}
