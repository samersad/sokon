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
    
    if (res.user != null) {
      var user = await SupabaseUtils.readUserFromSupabase(res.user!.id);
      if (user != null) {
        return user;
      } else {
        throw Exception("User data not found in database.");
      }
    }
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

    return MyUser(
      id: res.user!.id,
      name: name,
      email: email,
    );
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: dotenv.env['server_client_id'],
      );
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
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
        var user = await SupabaseUtils.readUserFromSupabase(res.user!.id);
        
        // Always extract current Google photo
        String? googlePhoto = res.user!.userMetadata?['avatar_url'] ?? googleUser.photoUrl;

        if (user == null) {
          user = MyUser(
            id: res.user!.id,
            name: res.user!.userMetadata?['full_name'] ?? googleUser.displayName ?? "",
            email: res.user!.email ?? googleUser.email,
            photoUrl: googlePhoto,
          );
          await SupabaseUtils.addUserToSupabase(user);
        } else {
          // If user exists, update their photo if it's different from what we have
          if (googlePhoto != null && user.photoUrl != googlePhoto) {
            user.photoUrl = googlePhoto;
            await SupabaseUtils.addUserToSupabase(user);
          }
        }
        return user;
      }
      throw Exception("Supabase Google Sign-In failed");
    } catch (e) {
      rethrow;
    }
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
}
