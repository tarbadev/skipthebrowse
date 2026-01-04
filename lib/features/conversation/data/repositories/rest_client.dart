import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:skipthebrowse/features/conversation/data/models/conversation_response.dart';
import 'package:skipthebrowse/features/auth/data/models/create_anonymous_user_request.dart';
import 'package:skipthebrowse/features/auth/data/models/auth_response_dto.dart';
import 'package:skipthebrowse/features/auth/data/models/register_user_request.dart';
import 'package:skipthebrowse/features/auth/data/models/login_request.dart';

import '../models/add_message_request.dart';
import '../models/conversation_list_response.dart';
import '../models/create_conversation_request.dart';
import '../models/search_result_response.dart';
import 'package:skipthebrowse/features/auth/data/models/merge_account_request.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _RestClient;

  @POST('/api/v1/conversations')
  Future<ConversationResponse> createConversation(
    @Body() CreateConversationRequest request,
  );

  @GET('/api/v1/conversations')
  Future<ConversationListResponse> listConversations(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/api/v1/conversations/search')
  Future<ConversationSearchResponse> searchConversations(
    @Query('q') String query,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/api/v1/conversations/{Id}')
  Future<ConversationResponse> getConversation(@Path('Id') String id);

  @POST('/api/v1/conversations/{Id}/respond')
  Future<ConversationResponse> addMessage(
    @Path('Id') String id,
    @Body() AddMessageRequest request,
  );

  @POST('/api/v1/auth/anonymous')
  Future<AuthResponseDto> createAnonymousUser(
    @Body() CreateAnonymousUserRequest request,
  );

  @POST('/api/v1/auth/register')
  Future<AuthResponseDto> registerUser(@Body() RegisterUserRequest request);

  @POST('/api/v1/auth/login')
  Future<AuthResponseDto> loginUser(@Body() LoginRequest request);

  @POST('/api/v1/auth/merge')
  Future<AuthResponseDto> mergeAnonymousAccount(
    @Body() MergeAccountRequest request,
  );
}
