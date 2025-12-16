import 'package:const_date_time/const_date_time.dart';
import 'package:skipthebrowse/features/conversation/data/models/conversation_response.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/recommendation.dart';

const messageId = '110ec58a-a0f2-4ac4-8393-c866d813b8d1';
const conversationId = '97b148c1-5f42-40cf-b11f-2fe63873f19a';
const recommendationId = '062a6211-46d7-417c-b9d8-9fc2725c206c';
const messageContent = 'I want to watch a recent movie';

const fixedDateTime = ConstDateTime(2025, 10, 23, 22, 35, 12);

MessageResponse messageResponse({
  String id = messageId,
  String content = messageContent,
  DateTime timestamp = fixedDateTime,
  String author = 'user',
  String type = 'question',
  RecommendationResponse? recommendation,
}) => MessageResponse(
  id: id,
  content: content,
  timestamp: timestamp,
  author: author,
  type: type,
  recommendation: recommendation,
);

Conversation conversation({
  String id = conversationId,
  List<Message> messages = const [],
  DateTime createdAt = fixedDateTime,
}) => Conversation(id: id, messages: messages, createdAt: createdAt);

Message message({
  String id = messageId,
  String content = messageContent,
  DateTime timestamp = fixedDateTime,
  String author = 'user',
  MessageType type = MessageType.question,
  Recommendation? recommendation,
}) => Message(
  id: id,
  content: content,
  timestamp: timestamp,
  author: author,
  type: type,
  recommendation: recommendation,
);

Recommendation recommendation({
  String id = recommendationId,
  String title = 'Ted',
  String description =
      'John Bennett, a man whose childhood wish of bringing his teddy bear to '
      'life came true, now must decide between keeping the relationship with '
      'the bear, Ted or his girlfriend, Lori.',
  int releaseYear = 2012,
  double rating = 6.9,
  double confidence = 0.603,
  List<Platform> platforms = const [
    Platform(
      name: 'Netflix',
      slug: 'netflix',
      url: 'https://example.com/netflix/ted',
      isPreferred: true,
    ),
  ],
}) => Recommendation(
  id: id,
  title: title,
  description: description,
  releaseYear: releaseYear,
  rating: rating,
  confidence: confidence,
  platforms: platforms,
);
