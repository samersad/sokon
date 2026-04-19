abstract class MessageStates {}

class MessageInitial extends MessageStates {}

class MessageLoading extends MessageStates {}

class MessageLoaded extends MessageStates {
  final List<Map<String, dynamic>> chats;
  MessageLoaded(this.chats);
}

class MessageError extends MessageStates {
  final String message;
  MessageError(this.message);
}
