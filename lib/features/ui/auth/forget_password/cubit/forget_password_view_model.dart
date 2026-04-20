import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../data/repository/auth/repository/auth_repository.dart';
import 'forget_password_states.dart';

@injectable
class ForgetPasswordViewModel extends Cubit<ForgetPasswordState> {
  final AuthRepository authRepository;
  ForgetPasswordViewModel(this.authRepository) : super(ForgetPasswordInitial());

  String? userEmail;
  bool hidePassword = true;
  void changePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> sendOTP(String email) async {
    userEmail = email;
    emit(ForgetPasswordLoading());
    try {
      await authRepository.resetPassword(email);
      emit(ForgetPasswordSuccess());
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }

  Future<void> verifyOTP(String token) async {
    if (userEmail == null) return;
    emit(ForgetPasswordLoading());
    try {
      await authRepository.verifyOTP(userEmail!, token);
      emit(OTPSuccess());
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    emit(ForgetPasswordLoading());
    try {
      await authRepository.updatePassword(newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(ForgetPasswordError(e.toString()));
    }
  }
}
