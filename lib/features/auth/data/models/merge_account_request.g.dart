// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merge_account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MergeAccountRequest _$MergeAccountRequestFromJson(Map<String, dynamic> json) =>
    MergeAccountRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$MergeAccountRequestToJson(
  MergeAccountRequest instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};
