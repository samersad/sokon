import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../core/model/RegisterResponse.dart';
import '../../../../../core/model/my_user.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../data/repository/auth/repository/auth_repository.dart';
import '../../../../../l10n/app_localizations.dart';
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
        final user = await authRepository.loginWithBackend(
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
      final myUser = await authRepository.signInWithGoogle();
      final user = _fromMyUser(myUser);

      final role = user.role?.trim();
      if (role == null || role.isEmpty) {
        emit(LoginNeedsRoleStates(user));
      } else {
        userCubit.updateUser(user);
        emit(LoginSuccessStates(user));
      }
    } catch (e) {
      emit(LoginErrorStates("Google Sign-In failed: ${e.toString()}"));
    }
  }

  Future<void> updateUserRole(RegisterUser user, String role, UserViewModel userCubit) async {
    try {
      emit(LoginLoadingStates());
      final normalizedRole = role.trim().toLowerCase();
      await authRepository.updateUserRole(_toMyUser(user), normalizedRole);
      user.role = normalizedRole;
      userCubit.updateUser(user);
      emit(LoginSuccessStates(user));
    } catch (e) {
      emit(LoginErrorStates("Failed to save user role: ${e.toString()}"));
    }
  }

  void showRoleSelectionDialog(
    BuildContext context,
    RegisterUser user,
    UserViewModel userCubit,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String? selectedDialogRole;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title:  Text(l10n.selectYourRole,style: AppStyles.bold20blackIner),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.owner),
                    value: 'owner',
                    groupValue: selectedDialogRole,
                    onChanged: (value) => setState(() => selectedDialogRole = value),
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.client),
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
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  RegisterUser _fromMyUser(MyUser user) {
    return RegisterUser(
      id: user.id,
      name: user.name,
      email: user.email,
      college: user.college,
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      role: user.role,
      photoUrl: user.photoUrl,
      fcmToken: user.fcmToken,
      createdAt: user.createdAt?.toIso8601String(),
    );
  }

  MyUser _toMyUser(RegisterUser user) {
    return MyUser(
      id: user.id ?? "",
      name: user.name ?? "",
      email: user.email ?? "",
      college: user.college,
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      role: user.role,
      photoUrl: user.photoUrl?.toString(),
      fcmToken: user.fcmToken?.toString(),
      createdAt: user.createdAt != null
          ? DateTime.tryParse(user.createdAt!)
          : null,
    );
  }
}
