import 'package:equatable/equatable.dart';
import 'interaction.dart';
import 'recommendation_with_status.dart';

class SearchSession extends Equatable {
  final String id;
  final List<Interaction> interactions;
  final List<RecommendationWithStatus> recommendations;
  final DateTime createdAt;

  const SearchSession({
    required this.id,
    required this.interactions,
    required this.recommendations,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, interactions, recommendations, createdAt];
}
