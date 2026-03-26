import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../data/repository/chat/repository/chat_repository.dart';
import 'message_states.dart';

@injectable
class MessageViewModel extends Cubit<MessageStates> {
  final ChatRepository chatRepository;
  MessageViewModel(this.chatRepository) : super(MessageInitial());

  void getChats(String userId) {
    emit(MessageLoading());
    try {
      chatRepository.getChats(userId).listen((snapshot) {
        emit(MessageLoaded(snapshot.docs));
      }, onError: (error) {
        emit(MessageError(error.toString()));
      });
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }
}
