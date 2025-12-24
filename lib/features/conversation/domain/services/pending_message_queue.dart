import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/conversation/domain/entities/pending_message.dart';

class PendingMessageQueue {
  static const String _queueKey = 'pending_messages_queue';
  final SharedPreferences _prefs;

  PendingMessageQueue(this._prefs);

  Future<void> enqueue(PendingMessage message) async {
    final messages = await getAll();
    messages.add(message);
    await _saveQueue(messages);
  }

  Future<List<PendingMessage>> getAll() async {
    final jsonString = _prefs.getString(_queueKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PendingMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PendingMessage>> getForConversation(String conversationId) async {
    final all = await getAll();
    return all.where((msg) => msg.conversationId == conversationId).toList();
  }

  Future<void> remove(PendingMessage message) async {
    final messages = await getAll();
    messages.removeWhere(
      (msg) =>
          msg.conversationId == message.conversationId &&
          msg.content == message.content &&
          msg.timestamp == message.timestamp,
    );
    await _saveQueue(messages);
  }

  Future<void> updateRetryCount(
    PendingMessage message,
    int newRetryCount,
  ) async {
    final messages = await getAll();
    final index = messages.indexWhere(
      (msg) =>
          msg.conversationId == message.conversationId &&
          msg.content == message.content &&
          msg.timestamp == message.timestamp,
    );

    if (index != -1) {
      messages[index] = message.copyWith(retryCount: newRetryCount);
      await _saveQueue(messages);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_queueKey);
  }

  Future<void> _saveQueue(List<PendingMessage> messages) async {
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    await _prefs.setString(_queueKey, json.encode(jsonList));
  }
}
