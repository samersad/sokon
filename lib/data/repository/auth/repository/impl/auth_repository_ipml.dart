import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../../core/model/my_user.dart';
import '../../data_sources/remote/auth_remote_data_source.dart';
import '../auth_repository.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<MyUser> login(String email, String password) =>
      remoteDataSource.login(email, password);

  @override
  Future<MyUser> register(String email, String password, String name) =>
      remoteDataSource.register(email, password, name);

  @override
  Future<MyUser> signInWithGoogle() => remoteDataSource.signInWithGoogle();

  @override
  Future<void> updateUserRole(MyUser user, String role) =>
      remoteDataSource.updateUserRole(user, role);

  @override
  Future<MyUser> updateProfile(MyUser user, String name, File? profileImage) =>
      remoteDataSource.updateProfile(user, name, profileImage);

  @override
  Future<void> signOut() => remoteDataSource.signOut();

  @override
  Future<void> resetPassword(String email) => remoteDataSource.resetPassword(email);

  @override
  Future<void> verifyOTP(String email, String token) => remoteDataSource.verifyOTP(email, token);

  @override
  Future<void> updatePassword(String newPassword) => remoteDataSource.updatePassword(newPassword);
}
