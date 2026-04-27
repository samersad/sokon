import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/supabase_utils.dart';
import '../chat_remote_data_source.dart';

@Injectable(as: ChatRemoteDataSource)
class ChatRemoteDataImpl implements ChatRemoteDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Stream<List<Map<String, dynamic>>> getChats(String userId) {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .map((event) {
          final chats = event.where((chat) {
            final users = chat['users'] as List? ?? [];
            return users.contains(userId);
          }).toList();

          chats.sort((a, b) {
            final aTime = _parseTimestamp(a['timestamp']);
            final bTime = _parseTimestamp(b['timestamp']);
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return chats;
        });
  }

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('timestamp', ascending: true)
        .map((messages) {
          final sortedMessages = List<Map<String, dynamic>>.from(messages);
          sortedMessages.sort((a, b) {
            final aTime = _parseTimestamp(a['timestamp']);
            final bTime = _parseTimestamp(b['timestamp']);
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return -1;
            if (bTime == null) return 1;
            final timeComparison = aTime.compareTo(bTime);
            if (timeComparison != 0) {
              return timeComparison;
            }

            final aId = a['id']?.toString() ?? '';
            final bId = b['id']?.toString() ?? '';
            return aId.compareTo(bId);
          });
          return sortedMessages;
        });
  }

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    final now = DateTime.now().toIso8601String();
    
    // 1. Create or Update the main chat record (upsert) FIRST
    // This ensures the chatId exists before we try to add a message to it
    await _client.from('chats').upsert({
      'id': chatId, 
      ...messageData['chatMetadata'],
      'timestamp': now,
    });

    // 2. Send the message
    await _client.from('messages').insert({
      'chat_id': chatId,
      ...messageData['messageData'],
      'timestamp': now,
    });

    final notificationData = messageData['notificationData'] as Map<String, dynamic>?;
    if (notificationData != null) {
      await SupabaseUtils.addChatNotificationToSupabase(
        receiverId: notificationData['receiverId'],
        senderId: notificationData['senderId'],
        senderName: notificationData['senderName'],
        chatId: notificationData['chatId'],
        message: notificationData['message'],
      );
    }
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
