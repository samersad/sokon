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
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) =>
      remoteDataSource.getMessages(chatId);

  @override
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) =>
      remoteDataSource.sendMessage(chatId, messageData);
}
