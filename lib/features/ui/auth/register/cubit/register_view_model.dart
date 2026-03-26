import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../core/model/my_user.dart';
import '../../../../../data/repository/auth/repository/auth_repository.dart';
import 'register_states.dart';

@injectable
class RegisterViewModel extends Cubit<RegisterStates> {
  final AuthRepository authRepository;
  RegisterViewModel(this.authRepository) : super(RegisterInitialStates());

  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  void changePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(ChangePasswordVisibilityState());
  }

  Future<void> register(UserViewModel userCubit) async {
    if (formKey.currentState?.validate() ?? false) {
      emit(RegisterLoadingStates());
      try {
        final user = await authRepository.register(
          emailCtrl.text,
          passwordCtrl.text,
          userCtrl.text,
        );
        emit(RegisterNeedsRoleStates(user));
      } catch (e) {
        emit(RegisterErrorStates(e.toString()));
      }
    }
  }

  Future<void> signInWithGoogle(UserViewModel userCubit) async {
    try {
      emit(RegisterLoadingStates());
      final user = await authRepository.signInWithGoogle();

      if (user.role == null) {
        emit(RegisterNeedsRoleStates(user));
      } else {
        userCubit.updateUser(user);
        emit(RegisterSuccessStates(user));
      }
    } catch (e) {
      emit(RegisterErrorStates("Google Sign-In failed: ${e.toString()}"));
    }
  }

  Future<void> updateUserRole(MyUser user, String role, UserViewModel userCubit) async {
    try {
      emit(RegisterLoadingStates());
      await authRepository.updateUserRole(user, role);
      userCubit.updateUser(user);
      emit(RegisterSuccessStates(user));
    } catch (e) {
      emit(RegisterErrorStates("Failed to save user role: ${e.toString()}"));
    }
  }

  void showRoleSelectionDialog(
      BuildContext context, MyUser user, UserViewModel userCubit) {
    String? selectedRole;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select your role"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Owner"),
                    value: 'owner',
                    groupValue: selectedRole,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Client"),
                    value: 'client',
                    groupValue: selectedRole,
                    onChanged: (value) => setState(() => selectedRole = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedRole != null) {
                      Navigator.pop(context);
                      updateUserRole(user, selectedRole!, userCubit);
                    }
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
