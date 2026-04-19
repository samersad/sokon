import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
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
        .map((event) => event.where((chat) {
              List users = chat['users'] ?? [];
              return users.contains(userId);
            }).toList());
  }

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('timestamp', ascending: false);
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
  }
}
