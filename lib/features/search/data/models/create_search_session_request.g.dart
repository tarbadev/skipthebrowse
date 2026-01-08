// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_search_session_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSearchSessionRequest _$CreateSearchSessionRequestFromJson(
  Map<String, dynamic> json,
) => CreateSearchSessionRequest(
  message: json['message'] as String,
  region: json['region'] as String? ?? 'US',
);

Map<String, dynamic> _$CreateSearchSessionRequestToJson(
  CreateSearchSessionRequest instance,
) => <String, dynamic>{'message': instance.message, 'region': instance.region};
