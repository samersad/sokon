import '../../../../../core/model/my_user.dart';

abstract class LoginStates {}

class LoginInitialStates extends LoginStates {}

class LoginLoadingStates extends LoginStates {}

class LoginErrorStates extends LoginStates {
  final String message;
  LoginErrorStates(this.message);
}

class LoginSuccessStates extends LoginStates {
  final MyUser user;
  LoginSuccessStates(this.user);
}

class LoginNeedsRoleStates extends LoginStates {
  final MyUser user;
  LoginNeedsRoleStates(this.user);
}

class ChangePasswordVisibilityState extends LoginStates {}
