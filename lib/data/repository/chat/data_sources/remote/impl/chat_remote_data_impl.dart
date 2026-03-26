import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../chat_remote_data_source.dart';

@Injectable(as: ChatRemoteDataSource)
class ChatRemoteDataImpl implements ChatRemoteDataSource {
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getChats(String userId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    // Send message to sub-collection
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData['messageData']);

    // Update main chat document
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .set(messageData['chatMetadata'], SetOptions(merge: true));
  }
}
