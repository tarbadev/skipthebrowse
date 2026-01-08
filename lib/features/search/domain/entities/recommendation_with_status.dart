import 'package:equatable/equatable.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';

enum RecommendationStatus { proposed, seen, willWatch, declined }

class RecommendationWithStatus extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int? releaseYear;
  final double? rating;
  final double confidence;
  final List<Platform> platforms;
  final RecommendationStatus status;
  final int interactionCount;
  final String? userFeedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecommendationWithStatus({
    required this.id,
    required this.title,
    this.description,
    this.releaseYear,
    this.rating,
    required this.confidence,
    required this.platforms,
    required this.status,
    required this.interactionCount,
    this.userFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    releaseYear,
    rating,
    confidence,
    platforms,
    status,
    interactionCount,
    userFeedback,
    createdAt,
    updatedAt,
  ];
}
