import 'package:injectable/injectable.dart';
import '../../data_sources/remote/chat_remote_data_source.dart';
import '../chat_repository.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Map<String, dynamic>>> getChats(String userId) =>
      remoteDataSource.getChats(userId);

  @override
  Future<Map<String, dynamic>> upsertChat(Map<String, dynamic> chatData) =>
      remoteDataSource.upsertChat(chatData);

  @override
  Future<Map<String, dynamic>> getChatById(String chatId) =>
      remoteDataSource.getChatById(chatId);

  @override
  Future<void> deleteChat(String chatId) => remoteDataSource.deleteChat(chatId);

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) =>
      remoteDataSource.getMessages(chatId);

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) =>
      remoteDataSource.sendMessage(chatId, messageData);

  @override
  Future<void> deleteMessage(String messageId) =>
      remoteDataSource.deleteMessage(messageId);
}
