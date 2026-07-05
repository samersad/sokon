import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/api/api_service .dart';
import 'package:sokon/cloudinary_service.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
import 'package:sokon/core/model/RegisterResponse.dart';
import 'package:sokon/core/services/firebase_cloud_messaging.dart';
import 'package:sokon/core/utils/phone_verification_utils.dart';
import '../../../../../../core/model/my_user.dart';
import '../auth_remote_data_source.dart';

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataImpl implements AuthRemoteDataSource {
  SupabaseClient get _client => Supabase.instance.client;
  final ApiService _apiService = ApiService();
  String? _passwordResetToken;

  @override
  Future<MyUser> login(String email, String password) async =>
      _toMyUser(await loginWithBackend(email, password));

  @override
  Future<RegisterUser> loginWithBackend(String email, String password) async {
    final response = await _apiService.login(email: email, password: password);
    return _saveBackendAuthResponse(response);
  }

  @override
  Future<MyUser> register(
    String email,
    String password,
    String name,
    String? college,
    String phoneNumber,
    String gender,
    String role,
  ) async => _toMyUser(
    await registerWithBackend(
      email,
      password,
      name,
      college,
      phoneNumber,
      gender,
      role,
    ),
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
  ) async {
    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      phone: phoneNumber,
      avatarId: 0,
      college: college?.trim().isEmpty == true ? null : college?.trim(),
      gender: gender,
      role: role.trim().toLowerCase(),
      phoneVerified: false,
    );
    return _saveBackendAuthResponse(response);
  }

  @override
  Future<RegisterUser> updateProfileWithBackend(
    RegisterUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  ) async {
    final userId = user.id;
    if (userId == null || userId.isEmpty) {
      throw Exception("User id is required to update profile.");
    }

    String? photoUrl = user.photoUrl?.toString();
    if (profileImage != null) {
      photoUrl = await CloudinaryService.uploadImage(profileImage);
      if (photoUrl == null || photoUrl.isEmpty) {
        throw Exception("Profile image upload failed.");
      }
    }

    final phoneVerified =
        PhoneVerificationUtils.isSamePhone(user.phoneNumber, phoneNumber) &&
        user.phoneVerified == true;

    final updatedUser = await _apiService.updateUser(
      userId: userId,
      name: name,
      email: user.email ?? "",
      phoneNumber: phoneNumber,
      college: college?.trim().isEmpty == true ? null : college?.trim(),
      gender: gender?.trim().isEmpty == true ? user.gender : gender?.trim(),
      role: user.role ?? "client",
      photoUrl: photoUrl,
      fcmToken: user.fcmToken,
      phoneVerified: phoneVerified,
    );
    updatedUser.phoneVerified ??= phoneVerified;

    await _cacheBackendUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(clientId: dotenv.env['server_client_id']);
      await signIn.signOut();
      await _ignoreErrors(signIn.disconnect());

      final GoogleSignInAccount googleUser = await signIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('No ID Token found.');

      final AuthResponse res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (res.user != null) {
        final googlePhoto =
            res.user!.userMetadata?['avatar_url'] ?? googleUser.photoUrl;
        final accessToken = res.session?.accessToken;

        final user = MyUser(
          id: res.user!.id,
          name:
              res.user!.userMetadata?['full_name'] ??
              googleUser.displayName ??
              "",
          email: res.user!.email ?? googleUser.email,
          role: res.user!.userMetadata?['role']?.toString(),
          photoUrl: googlePhoto?.toString(),
        );
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('No access token found.');
        }

        final exchanged = await _apiService.exchangeSession(accessToken);
        final backendUser = exchanged.user;
        final backendSession = exchanged.session;
        if (backendSession?.accessToken != null &&
            backendSession!.accessToken!.isNotEmpty) {
          await SharedPrefsHelper.saveData(
            key: "token",
            value: backendSession.accessToken!,
          );
        }
        if (backendUser != null) {
          // Only cache the user if they already have a role assigned.
          // If role is null, the user will be prompted to select one first.
          final backendRole = backendUser.role?.trim();
          if (backendRole != null && backendRole.isNotEmpty) {
            await _cacheBackendUser(backendUser);
          }
          return _toMyUser(backendUser);
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
    final normalizedRole = role.trim().toLowerCase();
    final updatedUser = await _apiService.upsertUser(
      RegisterUser(
        id: user.id,
        name: user.name,
        email: user.email,
        college: user.college,
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        role: normalizedRole,
        photoUrl: user.photoUrl,
        fcmToken: user.fcmToken,
        phoneVerified: user.phoneVerified ?? false,
        createdAt: user.createdAt?.toIso8601String(),
      ),
    );
    await _cacheBackendUser(updatedUser);
  }

  @override
  Future<MyUser> updateProfile(
    MyUser user,
    String name,
    String phoneNumber,
    String? college,
    String? gender,
    File? profileImage,
  ) async => _toMyUser(
    await updateProfileWithBackend(
      RegisterUser(
        id: user.id,
        name: user.name,
        email: user.email,
        college: user.college,
        phoneNumber: user.phoneNumber,
        gender: user.gender,
        role: user.role,
        photoUrl: user.photoUrl,
        fcmToken: user.fcmToken,
        phoneVerified: user.phoneVerified ?? false,
        createdAt: user.createdAt?.toIso8601String(),
      ),
      name,
      phoneNumber,
      college,
      gender,
      profileImage,
    ),
  );

  @override
  Future<void> signOut() async {
    final cachedUser = SharedPrefsHelper.getData(key: "cached_user");
    if (cachedUser is String && cachedUser.isNotEmpty) {
      final decoded = jsonDecode(cachedUser);
      if (decoded is Map<String, dynamic>) {
        await _ignoreErrors(
          FirebaseCloudMessaging.clearTokenForUser(
            RegisterUser.fromJson(decoded).id,
          ),
        );
      }
    }
    await _ignoreErrors(_apiService.logout());
    final GoogleSignIn signIn = GoogleSignIn.instance;
    await _ignoreErrors(
      signIn.initialize(clientId: dotenv.env['server_client_id']),
    );
    await _ignoreErrors(signIn.signOut());
    await _ignoreErrors(signIn.disconnect());
    await _ignoreErrors(_client.auth.signOut());
    await SharedPrefsHelper.removeData(key: "token");
    await SharedPrefsHelper.removeData(key: "cached_user");
  }

  @override
  Future<void> resetPassword(String email) async {
    _passwordResetToken = await _apiService.requestPasswordReset(email);
  }

  @override
  Future<void> verifyOTP(String email, String token) async {
    _passwordResetToken = await _apiService.verifyResetOTP(
      email: email,
      otp: token,
    );
  }

  @override
  Future<void> requestPhoneVerificationOTP(
    String phoneNumber, {
    String channel = 'sms',
  }) {
    return _apiService.requestPhoneVerificationOTP(
      phoneNumber: phoneNumber,
      channel: channel,
    );
  }

  @override
  Future<RegisterUser> verifyPhoneOTP(String phoneNumber, String otp) async {
    final user = await _apiService.verifyPhoneOTP(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    await _cacheBackendUser(user);
    return user;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final token = _passwordResetToken;
    if (token != null && token.isNotEmpty) {
      final response = await _apiService.confirmPasswordReset(
        token: token,
        password: newPassword,
      );
      await _saveBackendAuthResponse(response);
      _passwordResetToken = null;
      return;
    }

    final user = await _apiService.updatePassword(newPassword);
    await _cacheBackendUser(user);
  }

  Future<void> _saveSessionData({required MyUser user}) async {
    final accessToken = _client.auth.currentSession?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      await SharedPrefsHelper.saveData(key: "token", value: accessToken);
    }
    await _cacheUser(user);
  }

  Future<RegisterUser> _saveBackendAuthResponse(
    RegisterResponse response,
  ) async {
    final responseUser = response.user;
    if (responseUser == null) {
      throw Exception("User data not found in backend response.");
    }
    responseUser.phoneVerified ??= false;

    final token = response.session?.accessToken;
    if (token != null && token.isNotEmpty) {
      await SharedPrefsHelper.saveData(key: "token", value: token);
    }
    await SharedPrefsHelper.saveData(
      key: "cached_user",
      value: jsonEncode(responseUser.toSupaBase()),
    );
    return responseUser;
  }

  Future<void> _cacheBackendUser(RegisterUser user) async {
    await SharedPrefsHelper.saveData(
      key: "cached_user",
      value: jsonEncode(user.toSupaBase()),
    );
  }

  Future<void> _cacheUser(MyUser user) async {
    await SharedPrefsHelper.saveData(
      key: "cached_user",
      value: jsonEncode(user.toSupaBase()),
    );
  }

  MyUser _toMyUser(RegisterUser user) {
    final id = user.id;
    final name = user.name;
    final email = user.email;
    if (id == null || name == null || email == null) {
      throw Exception("User data is incomplete.");
    }
    return MyUser(
      id: id,
      name: name,
      email: email,
      college: user.college,
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      role: user.role,
      photoUrl: user.photoUrl?.toString(),
      fcmToken: user.fcmToken?.toString(),
      phoneVerified: user.phoneVerified ?? false,
      createdAt: user.createdAt != null
          ? DateTime.tryParse(user.createdAt!)
          : null,
    );
  }

  @override
  Future<void> deleteAccount(String? password) async {
    // Clear FCM token before deleting
    final cachedUser = SharedPrefsHelper.getData(key: "cached_user");
    if (cachedUser is String && cachedUser.isNotEmpty) {
      final decoded = jsonDecode(cachedUser);
      if (decoded is Map<String, dynamic>) {
        await _ignoreErrors(
          FirebaseCloudMessaging.clearTokenForUser(
            RegisterUser.fromJson(decoded).id,
          ),
        );
      }
    }

    // Call backend to delete the account and all associated data
    await _apiService.deleteAccount(password: password);

    // Sign out from all providers and clear local cache
    final GoogleSignIn signIn = GoogleSignIn.instance;
    await _ignoreErrors(
      signIn.initialize(clientId: dotenv.env['server_client_id']),
    );
    await _ignoreErrors(signIn.signOut());
    await _ignoreErrors(signIn.disconnect());
    await _ignoreErrors(_client.auth.signOut());
    await SharedPrefsHelper.removeData(key: "token");
    await SharedPrefsHelper.removeData(key: "cached_user");
  }

  Future<void> _ignoreErrors<T>(Future<T> future) async {
    try {
      await future;
    } catch (_) {}
  }
}
