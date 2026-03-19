import 'package:flutter/material.dart';
import '../../model/my_user.dart';

class UserProvider extends ChangeNotifier {
  MyUser? user;

  void updateUser(MyUser? newUser) {
    user = newUser;
    notifyListeners();
  }
}
