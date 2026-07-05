import 'package:injectable/injectable.dart';
import 'package:sokon/api/api_service .dart';
import '../chat_remote_data_source.dart';

@Injectable(as: ChatRemoteDataSource)
class ChatRemoteDataImpl implements ChatRemoteDataSource {
  final ApiService _apiService = ApiService();
  static const Duration _pollInterval = Duration(seconds: 3);

  @override
  Stream<List<Map<String, dynamic>>> getChats(String userId) {
    return _poll(() => _apiService.getChats(userId)).map(_sortChats);
  }

  @override
  Future<Map<String, dynamic>> upsertChat(
    Map<String, dynamic> chatData,
  ) async {
    return _apiService.upsertChat(chatData);
  }

  @override
  Future<Map<String, dynamic>> getChatById(String chatId) async {
    return _apiService.getChatById(chatId);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _apiService.deleteChat(chatId);
  }

  @override
  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _poll(() => _apiService.getMessages(chatId)).map(_sortMessages);
  }

  @override
  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    await _apiService.sendMessage(chatId, messageData);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _apiService.deleteMessage(messageId);
  }

  Stream<List<Map<String, dynamic>>> _poll(
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) async* {
    yield await fetch();
    yield* Stream.periodic(_pollInterval).asyncMap((_) => fetch());
  }

  List<Map<String, dynamic>> _sortChats(List<Map<String, dynamic>> chats) {
    final sortedChats = List<Map<String, dynamic>>.from(chats);
    sortedChats.sort((a, b) {
      final aTime = _parseTimestamp(a['timestamp']);
      final bTime = _parseTimestamp(b['timestamp']);
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return sortedChats;
  }

  List<Map<String, dynamic>> _sortMessages(List<Map<String, dynamic>> messages) {
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
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
