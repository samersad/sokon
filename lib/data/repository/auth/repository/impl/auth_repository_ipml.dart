import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../../core/model/RegisterResponse.dart';
import '../../../../../core/model/my_user.dart';
import '../../data_sources/remote/auth_remote_data_source.dart';
import '../auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<MyUser> login(String email, String password) =>
      remoteDataSource.login(email, password);

  @override
  Future<RegisterUser> loginWithBackend(String email, String password) =>
      remoteDataSource.loginWithBackend(email, password);

  @override
  Future<MyUser> register(
    String email,
    String password,
    String name,
    String? college,
    String phoneNumber,
    String gender,
    String role,
  ) => remoteDataSource.register(
    email,
    password,
    name,
    college,
    phoneNumber,
    gender,
    role,
  );

  @override
  Future<RegisterUser> registerWithBackend(
    String email,
    String password,
    String name,
    String? college,
    String phoneNumber,
    String gender,
    String role,
  ) => remoteDataSource.registerWithBackend(
    email,
    password,
    name,
    college,
    phoneNumber,
    gender,
    role,
  );

  @override
  Future<RegisterUser> updateProfileWithBackend(
    RegisterUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  ) => remoteDataSource.updateProfileWithBackend(
    user,
    name,
    phoneNumber,
    college,
    gender,
    profileImage,
  );

  @override
  Future<MyUser> signInWithGoogle() => remoteDataSource.signInWithGoogle();

  @override
  Future<void> updateUserRole(MyUser user, String role) =>
      remoteDataSource.updateUserRole(user, role);

  @override
  Future<MyUser> updateProfile(
    MyUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  ) => remoteDataSource.updateProfile(
    user,
    name,
    phoneNumber,
    college,
    gender,
    profileImage,
  );

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  Future<void> resetPassword(String email) =>
      remoteDataSource.resetPassword(email);

  @override
  Future<void> verifyOTP(String email, String token) =>
      remoteDataSource.verifyOTP(email, token);

  @override
  Future<void> requestPhoneVerificationOTP(
    String phoneNumber, {
    String channel = 'sms',
  }) => remoteDataSource.requestPhoneVerificationOTP(
    phoneNumber,
    channel: channel,
  );

  @override
  Future<RegisterUser> verifyPhoneOTP(String phoneNumber, String otp) =>
      remoteDataSource.verifyPhoneOTP(phoneNumber, otp);

  @override
  Future<void> updatePassword(String newPassword) =>
      remoteDataSource.updatePassword(newPassword);

  @override
  Future<void> deleteAccount(String? password) =>
      remoteDataSource.deleteAccount(password);
}
