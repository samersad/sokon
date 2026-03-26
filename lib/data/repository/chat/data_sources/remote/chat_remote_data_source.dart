import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatRemoteDataSource {
  Stream<QuerySnapshot<Map<String, dynamic>>> getChats(String userId);
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData);
}
