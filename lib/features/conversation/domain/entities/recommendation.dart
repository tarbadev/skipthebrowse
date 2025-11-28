import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int? releaseYear;
  final double? rating;
  final double confidence;
  final List<Platform> platforms;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.releaseYear,
    required this.rating,
    required this.confidence,
    required this.platforms,
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
  ];
}

class Platform extends Equatable {
  final String name;
  final String slug;
  final String url;
  final bool isPreferred;

  const Platform({
    required this.name,
    required this.slug,
    required this.url,
    required this.isPreferred,
  });

  @override
  List<Object?> get props => [name, slug, url, isPreferred];
}
