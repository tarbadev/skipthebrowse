import 'package:const_date_time/const_date_time.dart';
import 'package:skipthebrowse/features/conversation/data/models/conversation_response.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/conversation.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/message.dart';

const messageId = '110ec58a-a0f2-4ac4-8393-c866d813b8d1';
const conversationId = '97b148c1-5f42-40cf-b11f-2fe63873f19a';
const messageContent = 'I want to watch a recent movie';

const fixedDateTime = ConstDateTime(2025, 10, 23, 22, 35, 12);

MessageResponse messageResponse({
  String id = messageId,
  String content = messageContent,
  DateTime timestamp = fixedDateTime,
  String author = 'user',
}) => MessageResponse(
  id: id,
  content: content,
  timestamp: timestamp,
  author: author,
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
}) => Message(id: id, content: content, timestamp: timestamp, author: author);
