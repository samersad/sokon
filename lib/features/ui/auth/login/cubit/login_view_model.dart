import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../core/model/my_user.dart';
import '../../../../../data/repository/auth/repository/auth_repository.dart';
import 'login_states.dart';

@injectable
class LoginViewModel extends Cubit<LoginStates> {
  final AuthRepository authRepository;
  LoginViewModel(this.authRepository) : super(LoginInitialStates());

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  void changePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> login(UserViewModel userCubit) async {
    if (formKey.currentState?.validate() ?? false) {
      emit(LoginLoadingStates());
      try {
        final user = await authRepository.login(
          emailCtrl.text,
          passwordCtrl.text,
        );
        userCubit.updateUser(user);
        emit(LoginSuccessStates(user));
      } catch (e) {
        emit(LoginErrorStates(e.toString()));
      }
    }
  }

  Future<void> signInWithGoogle(UserViewModel userCubit) async {
    try {
      emit(LoginLoadingStates());
      final user = await authRepository.signInWithGoogle();

      if (user.role == null) {
        emit(LoginNeedsRoleStates(user));
      } else {
        userCubit.updateUser(user);
        emit(LoginSuccessStates(user));
      }
    } catch (e) {
      emit(LoginErrorStates("Google Sign-In failed: ${e.toString()}"));
    }
  }

  Future<void> updateUserRole(MyUser user, String role, UserViewModel userCubit) async {
    try {
      emit(LoginLoadingStates());
      await authRepository.updateUserRole(user, role);
      userCubit.updateUser(user);
      emit(LoginSuccessStates(user));
    } catch (e) {
      emit(LoginErrorStates("Failed to save user role: ${e.toString()}"));
    }
  }

  void showRoleSelectionDialog(
    BuildContext context,
    MyUser user,
    UserViewModel userCubit,
  ) {
    String? selectedDialogRole;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text("Select your role"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Owner"),
                    value: 'owner',
                    groupValue: selectedDialogRole,
                    onChanged: (value) => setState(() => selectedDialogRole = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Client"),
                    value: 'client',
                    groupValue: selectedDialogRole,
                    onChanged: (value) => setState(() => selectedDialogRole = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedDialogRole == null || selectedDialogRole!.isEmpty) {
                      return;
                    }
                    Navigator.pop(dialogContext);
                    updateUserRole(user, selectedDialogRole!, userCubit);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
