import 'package:equatable/equatable.dart';

class SearchSessionSummary extends Equatable {
  final String id;
  final String? initialMessage;
  final String previewText;
  final int interactionCount;
  final int recommendationCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SearchSessionSummary({
    required this.id,
    this.initialMessage,
    required this.previewText,
    required this.interactionCount,
    required this.recommendationCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    initialMessage,
    previewText,
    interactionCount,
    recommendationCount,
    createdAt,
    updatedAt,
  ];
}
