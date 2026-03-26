import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../data/repository/chat/repository/chat_repository.dart';
import 'chat_states.dart';

@injectable
class ChatViewModel extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  ChatViewModel(this.chatRepository) : super(ChatInitial());

  StreamSubscription? _messagesSubscription;

  void getMessages(String chatId) {
    emit(ChatLoading());
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = chatRepository.getMessages(chatId).listen((snapshot) {
        if (!isClosed) {
          emit(ChatMessagesLoaded(snapshot.docs));
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
  }) async {
    if (message.trim().isEmpty) return;

    final msg = message.trim();

    try {
      Map<String, dynamic> messageData = {
        'messageData': {
          'senderId': senderId,
          'message': msg,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'chatMetadata': {
          'lastMessage': msg,
          'timestamp': FieldValue.serverTimestamp(),
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

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
