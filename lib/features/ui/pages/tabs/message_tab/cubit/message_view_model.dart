import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'message_states.dart';

class MessageViewModel extends Cubit<MessageStates> {
  MessageViewModel() : super(MessageInitial());

  void getChats(String userId) {
    emit(MessageLoading());
    try {
      FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        emit(MessageLoaded(snapshot.docs));
      }, onError: (error) {
        emit(MessageError(error.toString()));
      });
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}
