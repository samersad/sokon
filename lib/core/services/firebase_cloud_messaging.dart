import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sokon/api/api_service .dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
import 'package:sokon/core/model/RegisterResponse.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseCloudMessaging {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _activeUserId;
  static final ApiService _apiService = ApiService();

  static Future<void> requestPermission() async {
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<String?> getToken() async {
    final String? token = await messaging.getToken();
    debugPrint(token);
    return token;
  }

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    await requestPermission();
    await onForegroundFcm();
    await onBackgroundFcm();
    await getToken();
    _isInitialized = true;
  }

  static Future<void> syncTokenForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return;
    }

    _activeUserId = userId;
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      await _saveFcmToken(userId, token);
    }

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((newToken) async {
      if (_activeUserId == null || newToken.isEmpty) {
        return;
      }

      await _saveFcmToken(_activeUserId!, newToken);
    });
  }

  static Future<void> clearTokenForUser(String? userId) async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    if (userId != null && userId.isNotEmpty) {
      await _saveFcmToken(userId, null);
    }

    _activeUserId = null;
  }

  static Future<void> onForegroundFcm() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final RemoteNotification? notification = message.notification;
      final String? title = notification?.title ?? message.data['title'];
      final String? body = notification?.body ?? message.data['body'];
      final String? imageUrl =
          message.data['imageUrl'] ??
          notification?.android?.imageUrl ??
          notification?.apple?.imageUrl;

      if (title == null || body == null) {
        return;
      }

      final androidDetails = await _buildAndroidNotificationDetails(
        channel: channel,
        imageUrl: imageUrl,
      );

      _flutterLocalNotificationsPlugin.show(
        id: notification?.hashCode ?? message.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: androidDetails,
        ),
      );
    });
  }

  static Future<void> onBackgroundFcm() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<AndroidNotificationDetails> _buildAndroidNotificationDetails({
    required AndroidNotificationChannel channel,
    String? imageUrl,
  }) async {
    final imageBytes = await _downloadImageBytes(imageUrl);
    final largeIcon = imageBytes == null
        ? null
        : ByteArrayAndroidBitmap(imageBytes);

    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: largeIcon,
      styleInformation: imageBytes == null
          ? null
          : BigPictureStyleInformation(
              ByteArrayAndroidBitmap(imageBytes),
              largeIcon: ByteArrayAndroidBitmap(imageBytes),
              hideExpandedLargeIcon: true,
            ),
    );
  }

  static Future<Uint8List?> _downloadImageBytes(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveFcmToken(String userId, String? token) async {
    try {
      // Read the cached user to populate name/email/role fields for the PATCH.
      // If the cache is missing (e.g. on first launch before login completes),
      // we still attempt the PATCH with only the fields we know.
      RegisterUser? decoded;
      final cachedUser = SharedPrefsHelper.getData(key: "cached_user");
      if (cachedUser is String && cachedUser.isNotEmpty) {
        try {
          decoded = RegisterUser.fromJson(
            Map<String, dynamic>.from(jsonDecode(cachedUser) as Map),
          );
          if (decoded.id != null && decoded.id != userId) {
            // Cached user belongs to a different account — skip to avoid
            // clobbering the wrong user record, but still sync the token
            // using a bare PATCH with empty profile fields.
            debugPrint(
              'FCM: cached user id (${decoded.id}) != target userId ($userId) — '
              'syncing token without cached profile data.',
            );
            decoded = null;
          }
        } catch (e) {
          debugPrint('FCM: failed to parse cached user: $e');
          decoded = null;
        }
      }

      final updatedUser = await _apiService.updateUser(
        userId: userId,
        name: decoded?.name ?? "",
        email: decoded?.email ?? "",
        phoneNumber: decoded?.phoneNumber ?? "",
        college: decoded?.college,
        gender: decoded?.gender,
        role: decoded?.role ?? "client",
        photoUrl: decoded?.photoUrl,
        fcmToken: token,
      );

      // Refresh the local cache so future reads reflect the new token.
      await SharedPrefsHelper.saveData(
        key: "cached_user",
        value: jsonEncode(updatedUser.toSupaBase()),
      );
      debugPrint('FCM: token ${token == null ? 'cleared' : 'saved'} for user $userId');
    } catch (e) {
      // Log instead of swallowing so failures are visible in debug output.
      debugPrint('FCM: _saveFcmToken failed for user $userId: $e');
    }
  }
}
