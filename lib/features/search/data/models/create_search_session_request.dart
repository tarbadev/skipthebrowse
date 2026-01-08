import 'package:json_annotation/json_annotation.dart';

part 'create_search_session_request.g.dart';

@JsonSerializable()
class CreateSearchSessionRequest {
  final String message;
  final String region;

  CreateSearchSessionRequest({required this.message, this.region = 'US'});

  factory CreateSearchSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSearchSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSearchSessionRequestToJson(this);
}
