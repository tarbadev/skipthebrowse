import 'package:equatable/equatable.dart';

class PendingMessage extends Equatable {
  final String conversationId;
  final String content;
  final DateTime timestamp;
  final int retryCount;

  const PendingMessage({
    required this.conversationId,
    required this.content,
    required this.timestamp,
    this.retryCount = 0,
  });

  PendingMessage copyWith({
    String? conversationId,
    String? content,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return PendingMessage(
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory PendingMessage.fromJson(Map<String, dynamic> json) {
    return PendingMessage(
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [conversationId, content, timestamp, retryCount];
}
