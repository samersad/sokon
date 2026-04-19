abstract class ChatRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getChats(String userId);
  Stream<List<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData);
}
