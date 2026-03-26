import 'dart:io';
import '../../../../../core/model/my_user.dart';

abstract class AuthRepository {
  Future<MyUser> login(String email, String password);
  Future<MyUser> register(String email, String password, String name);
  Future<MyUser> signInWithGoogle();
  Future<void> updateUserRole(MyUser user, String role);
  Future<MyUser> updateProfile(MyUser user, String name, File? profileImage);
  Future<void> signOut();
}
