import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../data/repository/chat/repository/chat_repository.dart';
import 'chat_states.dart';

@injectable
class ChatViewModel extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  ChatViewModel(this.chatRepository) : super(ChatInitial());

  StreamSubscription? _messagesSubscription;

  Future<void> upsertChat({
    required String chatId,
    required String senderId,
    required String senderName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverName,
    required String? receiverPhotoUrl,
  }) async {
    if (chatId.isEmpty || senderId.isEmpty || receiverId.isEmpty) {
      return;
    }

    try {
      await chatRepository.upsertChat({
        'id': chatId,
        'lastMessage': '',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'users': [senderId, receiverId],
        'displayNames': {
          senderId: senderName,
          receiverId: receiverName,
        },
        'displayPhotos': {
          senderId: senderPhotoUrl,
          receiverId: receiverPhotoUrl,
        },
      });
    } catch (e) {
      if (!isClosed) {
        emit(ChatError(e.toString()));
      }
      rethrow;
    }
  }

  void getMessages(String chatId) {
    emit(ChatLoading());
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = chatRepository.getMessages(chatId).listen((messages) {
        if (!isClosed) {
          emit(ChatMessagesLoaded(messages));
        }
      }, onError: (error) {
        if (!isClosed) {
          emit(ChatError(error.toString()));
        }
      });
    } catch (e) {
      if (!isClosed) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverName,
    required String? receiverPhotoUrl,
    required String message,
    String? imageUrl,
  }) async {
    final msg = message.trim();
    final uploadedImageUrl = imageUrl?.trim();
    final hasImage = uploadedImageUrl != null && uploadedImageUrl.isNotEmpty;
    if (msg.isEmpty && !hasImage) return;

    final previewText = msg.isNotEmpty ? msg : 'Photo';
    final notificationMessage = msg.isNotEmpty ? msg : 'Sent a photo';
    final storedMessage = _buildStoredMessage(
      text: msg,
      imageUrl: uploadedImageUrl,
    );

    try {
      Map<String, dynamic> messageData = {
        'messageData': {
          'senderId': senderId,
          'message': storedMessage,
        },
        'notificationData': {
          'receiverId': receiverId,
          'senderId': senderId,
          'senderName': senderName,
          'chatId': chatId,
          'message': notificationMessage,
        },
        'chatMetadata': {
          'lastMessage': previewText,
          'users': [senderId, receiverId],
          'displayNames': {
            senderId: senderName,
            receiverId: receiverName,
          },
          'displayPhotos': {
            senderId: senderPhotoUrl,
            receiverId: receiverPhotoUrl,
          }
        }
      };

      await chatRepository.sendMessage(chatId, messageData);
    } catch (e) {
      if (!isClosed) {
        emit(ChatError(e.toString()));
      }
    }
  }

  String _buildStoredMessage({
    required String text,
    required String? imageUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    if (!hasImage) {
      return text;
    }

    if (text.isEmpty) {
      return '__image__:$imageUrl';
    }

    return '__image__:$imageUrl\n__caption__:$text';
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
