import 'package:json_annotation/json_annotation.dart';

part 'merge_account_request.g.dart';

@JsonSerializable()
class MergeAccountRequest {
  final String email;
  final String password;

  const MergeAccountRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$MergeAccountRequestToJson(this);
}
