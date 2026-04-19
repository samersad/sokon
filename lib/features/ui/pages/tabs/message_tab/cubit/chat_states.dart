abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;
  ChatMessagesLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
