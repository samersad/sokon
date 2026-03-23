import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MessageStates {}

class MessageInitial extends MessageStates {}

class MessageLoading extends MessageStates {}

class MessageLoaded extends MessageStates {
  final List<QueryDocumentSnapshot> chats;
  MessageLoaded(this.chats);
}

class MessageError extends MessageStates {
  final String message;
  MessageError(this.message);
}
