import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/model/my_user.dart';
import '../../../../../../supabase_utils.dart';
import '../auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataImpl implements AuthRemoteDataSource {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<MyUser> login(String email, String password) async {
    final AuthResponse res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (res.user != null) return _resolveUserProfile(res.user!);
    throw Exception("Authentication failed");
  }

  @override
  Future<MyUser> register(String email, String password, String name) async {
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    
    if (res.user == null) throw Exception("Registration failed");

    final user = MyUser(
      id: res.user!.id,
      name: name,
      email: email,
    );

    await SupabaseUtils.addUserToSupabase(user);
    return user;
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: dotenv.env['server_client_id'],
      );
      await signIn.signOut();
      await signIn.disconnect().catchError((_) {});

      final GoogleSignInAccount? googleUser = await signIn.authenticate();
      if (googleUser == null) {
        throw Exception("Google Sign-In cancelled");
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('No ID Token found.');

      final AuthResponse res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (res.user != null) {
        return _resolveUserProfile(
          res.user!,
          fallbackName: googleUser.displayName,
          fallbackEmail: googleUser.email,
          fallbackPhotoUrl: googleUser.photoUrl,
        );
      }
      throw Exception("Supabase Google Sign-In failed");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MyUser?> restoreSession() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;
    return _resolveUserProfile(currentUser);
  }

  @override
  Future<void> updateUserRole(MyUser user, String role) async {
    user.role = role;
    await SupabaseUtils.addUserToSupabase(user);
  }

  @override
  Future<MyUser> updateProfile(MyUser user, String name, File? profileImage) async {
    String? photoUrl = user.photoUrl;
    if (profileImage != null) {
      photoUrl = await SupabaseUtils.uploadFile(
        file: profileImage,
        bucket: 'profiles',
        folder: user.id,
      );
    }

    user.name = name;
    user.photoUrl = photoUrl;

    await SupabaseUtils.addUserToSupabase(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;
    await signIn.signOut().catchError((_) {});
    await signIn.disconnect().catchError((_) {});
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyOTP(String email, String token) async {
    await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<MyUser> _resolveUserProfile(
    User authUser, {
    String? fallbackName,
    String? fallbackEmail,
    String? fallbackPhotoUrl,
  }) async {
    final existingUser = await SupabaseUtils.readUserFromSupabase(authUser.id);
    final metadataPhoto =
        _readMetadataString(authUser.userMetadata, 'avatar_url');

    if (existingUser != null) {
      final latestPhoto = fallbackPhotoUrl ?? metadataPhoto;
      final hasSavedCustomPhoto =
          existingUser.photoUrl != null && existingUser.photoUrl!.isNotEmpty;

      if (!hasSavedCustomPhoto &&
          latestPhoto != null &&
          latestPhoto != existingUser.photoUrl) {
        existingUser.photoUrl = latestPhoto;
        await SupabaseUtils.addUserToSupabase(existingUser);
      }
      return existingUser;
    }

    final user = MyUser(
      id: authUser.id,
      name:
          fallbackName ??
          _readMetadataString(authUser.userMetadata, 'full_name') ??
          _readMetadataString(authUser.userMetadata, 'name') ??
          _deriveNameFromEmail(authUser.email),
      email: fallbackEmail ?? authUser.email ?? '',
      photoUrl: fallbackPhotoUrl ?? metadataPhoto,
    );

    await SupabaseUtils.addUserToSupabase(user);
    return user;
  }

  String? _readMetadataString(Map<String, dynamic>? metadata, String key) {
    final value = metadata?[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  String _deriveNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'User';
    return email.split('@').first;
  }
}
