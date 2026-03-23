import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../../core/model/my_user.dart';
import '../../../../../firebase_utils.dart';
import 'login_states.dart';

class LoginViewModel extends Cubit<LoginStates> {
  LoginViewModel() : super(LoginInitialStates());

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
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text,
          password: passwordCtrl.text,
        );

        if (credential.user != null) {
          var user = await FireBaseUtils.readUserFromFireStore(credential.user!.uid);
          if (user != null) {
            userCubit.updateUser(user);
            emit(LoginSuccessStates(user));
          } else {
            emit(LoginErrorStates("User data not found in database."));
          }
        }
      } on FirebaseAuthException catch (e) {
        emit(LoginErrorStates(e.message ?? "Authentication failed"));
      } catch (e) {
        emit(LoginErrorStates("An unexpected error occurred: ${e.toString()}"));
      }
    }
  }

  Future<void> signInWithGoogle(UserViewModel userCubit) async {
    try {
      emit(LoginLoadingStates());
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: dotenv.env['server_client_id'],
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        emit(LoginInitialStates());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      var firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        var user = await FireBaseUtils.readUserFromFireStore(firebaseUser.uid);
        if (user == null || user.role == null) {
          MyUser newUser = MyUser(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "",
            email: firebaseUser.email ?? "",
            role: null,
            photoUrl: firebaseUser.photoURL,
          );
          emit(LoginNeedsRoleStates(newUser));
        } else {
          // Existing user - Update photoUrl if changed
          if (user.photoUrl != firebaseUser.photoURL) {
            user.photoUrl = firebaseUser.photoURL;
            await FireBaseUtils.addUserToFirestore(user);
          }
          userCubit.updateUser(user);
          emit(LoginSuccessStates(user));
        }
      }
    } catch (e) {
      emit(LoginErrorStates("Google Sign-In failed: ${e.toString()}"));
    }
  }

  Future<void> updateUserRole(MyUser user, String role,UserViewModel userCubit) async {
    try {
      emit(LoginLoadingStates());
      user.role = role;
      await FireBaseUtils.addUserToFirestore(user);
      userCubit.updateUser(user);
      emit(LoginSuccessStates(user));
    } catch (e) {
      emit(LoginErrorStates("Failed to save user role: ${e.toString()}"));
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
