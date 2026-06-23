import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/core/cache/cubit_manger/user_states.dart';
import '../../model/RegisterResponse.dart';
@lazySingleton
class UserViewModel extends Cubit<UserState> {
  UserViewModel() : super(UserInitial());

  RegisterUser? _user;
  RegisterUser? get user => _user;

  void updateUser(RegisterUser? newUser) {
    _user = newUser;
    emit(UserUpdated(newUser));
  }
}
