import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokon/core/cache/cubit_manger/user_states.dart';
import '../../model/my_user.dart';
class UserViewModel extends Cubit<UserState> {
  UserViewModel() : super(UserInitial());

  MyUser? _user;
  MyUser? get user => _user;

  void updateUser(MyUser? newUser) {
    _user = newUser;
    emit(UserUpdated(newUser));
  }
}
