// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_recommendation_status_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateRecommendationStatusRequest _$UpdateRecommendationStatusRequestFromJson(
  Map<String, dynamic> json,
) => UpdateRecommendationStatusRequest(
  status: json['status'] as String,
  feedback: json['feedback'] as String?,
);

Map<String, dynamic> _$UpdateRecommendationStatusRequestToJson(
  UpdateRecommendationStatusRequest instance,
) => <String, dynamic>{
  'status': instance.status,
  'feedback': instance.feedback,
};
