import '../../../../../core/model/RegisterResponse.dart';

abstract class RegisterStates {}

class RegisterInitialStates extends RegisterStates {}

class RegisterLoadingStates extends RegisterStates {}

class RegisterSuccessStates extends RegisterStates {
  final RegisterUser user;
  RegisterSuccessStates(this.user);
}

class RegisterNeedsRoleStates extends RegisterStates {
  final RegisterUser user;
  RegisterNeedsRoleStates(this.user);
}

class RegisterErrorStates extends RegisterStates {
  final String errorMessage;
  RegisterErrorStates(this.errorMessage);
}

class ChangePasswordVisibilityState extends RegisterStates {}

class RegisterFormChangedState extends RegisterStates {}
