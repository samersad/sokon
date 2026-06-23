import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../core/model/RegisterResponse.dart';
import '../../../../../core/model/my_user.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../data/repository/auth/repository/auth_repository.dart';
import 'register_states.dart';

@injectable
class RegisterViewModel extends Cubit<RegisterStates> {
  final AuthRepository authRepository;
  RegisterViewModel(this.authRepository) : super(RegisterInitialStates());

  static const List<String> genderOptions = ['male', 'female'];
  static const List<String> roleOptions = ['client', 'owner'];

  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedGender = genderOptions.first;
  String? selectedRole;
  RegisterUser? pendingGoogleUser;
  bool hidePassword = true;

  void changePasswordVisibility() {
    hidePassword = !hidePassword;
    emit(ChangePasswordVisibilityState());
  }

  void setGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }
    selectedGender = value;
    emit(RegisterFormChangedState());
  }

  void setRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }
    selectedRole = value;
    if (selectedRole == 'owner') {
      collegeCtrl.clear();
    }
    emit(RegisterFormChangedState());
  }

  bool get isOwner => selectedRole == 'owner';
  bool get hasPendingGoogleUser => pendingGoogleUser != null;

  Future<void> register(UserViewModel userCubit) async {
    if (formKey.currentState?.validate() ?? false) {
      final role = selectedRole?.trim();
      if (role == null || role.isEmpty) {
        emit(RegisterErrorStates("Please select a role"));
        return;
      }
      emit(RegisterLoadingStates());
      try {
        final user = await authRepository.registerWithBackend(
          emailCtrl.text,
          passwordCtrl.text,
          userCtrl.text,
          isOwner ? null : collegeCtrl.text,
          phoneCtrl.text,
          selectedGender,
          role,
        );
        userCubit.updateUser(user);
        emit(RegisterSuccessStates(user));
      } catch (e) {
        emit(RegisterErrorStates(e.toString()));
      }
    }
  }

  Future<void> signInWithGoogle(UserViewModel userCubit) async {
    try {
      emit(RegisterLoadingStates());
      final user = _fromMyUser(await authRepository.signInWithGoogle());

      if (user.gender == null || user.gender!.trim().isEmpty) {
        user.gender = selectedGender;
      }

      final role = selectedRole?.trim().toLowerCase();
      if ((user.role == null || user.role!.trim().isEmpty) &&
          role != null &&
          role.isNotEmpty) {
        await updateUserRole(user, role, userCubit);
      } else if (user.role == null || user.role!.trim().isEmpty) {
        pendingGoogleUser = user;
        emit(RegisterNeedsRoleStates(user));
      } else {
        pendingGoogleUser = null;
        userCubit.updateUser(user);
        emit(RegisterSuccessStates(user));
      }
    } catch (e) {
      emit(RegisterErrorStates("Google Sign-In failed: ${e.toString()}"));
    }
  }

  Future<void> updateUserRole(RegisterUser user, String role, UserViewModel userCubit) async {
    try {
      emit(RegisterLoadingStates());
      final normalizedRole = role.trim().toLowerCase();
      await authRepository.updateUserRole(_toMyUser(user), normalizedRole);
      user.role = normalizedRole;
      pendingGoogleUser = null;
      userCubit.updateUser(user);
      emit(RegisterSuccessStates(user));
    } catch (e) {
      emit(RegisterErrorStates("Failed to save user role: ${e.toString()}"));
    }
  }

  Future<void> confirmPendingGoogleRole(UserViewModel userCubit) async {
    final user = pendingGoogleUser;
    final role = selectedRole?.trim();
    if (user == null || role == null || role.isEmpty) {
      emit(RegisterErrorStates("Please select a role"));
      return;
    }
    await updateUserRole(user, role, userCubit);
  }

  void showRoleSelectionDialog(
    BuildContext context,
    RegisterUser user,
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
              title:  Text("Select your role",style: AppStyles.bold20blackIner),
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
