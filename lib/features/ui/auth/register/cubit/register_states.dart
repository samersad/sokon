import '../../../../../core/model/my_user.dart';

abstract class RegisterStates {}

class RegisterInitialStates extends RegisterStates {}

class RegisterLoadingStates extends RegisterStates {}

class RegisterSuccessStates extends RegisterStates {
  final MyUser user;
  RegisterSuccessStates(this.user);
}

class RegisterNeedsRoleStates extends RegisterStates {
  final MyUser user;
  RegisterNeedsRoleStates(this.user);
}

class RegisterErrorStates extends RegisterStates {
  final String errorMessage;
  RegisterErrorStates(this.errorMessage);
}

class ChangePasswordVisibilityState extends RegisterStates {}

class RegisterFormChangedState extends RegisterStates {}
