abstract class ChatRepository {
  Stream<List<Map<String, dynamic>>> getChats(String userId);
  Future<Map<String, dynamic>> upsertChat(Map<String, dynamic> chatData);
  Future<Map<String, dynamic>> getChatById(String chatId);
  Future<void> deleteChat(String chatId);
  Stream<List<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData);
  Future<void> deleteMessage(String messageId);
}
