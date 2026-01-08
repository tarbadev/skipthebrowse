import 'package:json_annotation/json_annotation.dart';

part 'update_recommendation_status_request.g.dart';

@JsonSerializable()
class UpdateRecommendationStatusRequest {
  final String status;
  final String? feedback;

  UpdateRecommendationStatusRequest({required this.status, this.feedback});

  factory UpdateRecommendationStatusRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateRecommendationStatusRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateRecommendationStatusRequestToJson(this);
}
