import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
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

  Future<void> updatePhoneVerification({
    required bool verified,
    String? phoneNumber,
  }) async {
    final currentUser = _user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      phoneVerified: verified,
    );
    _user = updatedUser;
    await SharedPrefsHelper.saveData(
      key: "cached_user",
      value: jsonEncode(updatedUser.toSupaBase()),
    );
    emit(UserUpdated(updatedUser));
  }
}
