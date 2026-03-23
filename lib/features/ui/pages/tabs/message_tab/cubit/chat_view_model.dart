import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_states.dart';

class ChatViewModel extends Cubit<ChatState> {
  ChatViewModel() : super(ChatInitial());

  StreamSubscription? _messagesSubscription;

  void getMessages(String chatId) {
    emit(ChatLoading());
    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
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
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'message': msg,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat metadata
      Map<String, dynamic> updateData = {
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
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .set(updateData, SetOptions(merge: true));
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
