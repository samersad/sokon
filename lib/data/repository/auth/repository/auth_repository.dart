import 'dart:io';
import '../../../../../core/model/RegisterResponse.dart';
import '../../../../../core/model/my_user.dart';

abstract class AuthRepository {
  Future<MyUser> login(String email, String password);
  Future<RegisterUser> loginWithBackend(String email, String password);
  Future<MyUser> register(
    String email,
    String password,
    String name,
    String? college,
    String phoneNumber,
    String gender,
    String role,
  );
  Future<RegisterUser> registerWithBackend(
    String email,
    String password,
    String name,
    String? college,
    String phoneNumber,
    String gender,
    String role,
  );
  Future<RegisterUser> updateProfileWithBackend(
    RegisterUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  );
  Future<MyUser> signInWithGoogle();
  Future<void> updateUserRole(MyUser user, String role);
  Future<MyUser> updateProfile(
    MyUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  );
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> verifyOTP(String email, String token);
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount(String? password);
}
