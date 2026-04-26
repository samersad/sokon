import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/core/model/notification.dart';
import 'package:sokon/supabase_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_states.dart';

@lazySingleton
class NotificationViewModel extends Cubit<NotificationStates> {
  NotificationViewModel() : super(NotificationInitial());

  StreamSubscription? _notificationsSubscription;
  String? _currentUserId;
  bool _isRefreshingSession = false;
  final Set<String> _baselineNotificationIds = <String>{};
  bool _hasEstablishedBaseline = false;

  Future<void> listenToNotifications(String userId) async {
    if (_currentUserId == userId &&
        _notificationsSubscription != null &&
        state is! NotificationError) {
      return;
    }

    final hasValidSession = await _ensureValidSession();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (!hasValidSession || currentUser?.id != userId) {
      emit(
        NotificationError('Your session has expired. Please sign in again.'),
      );
      return;
    }

    await _subscribe(userId);
  }

  Future<bool> _ensureValidSession() async {
    final client = Supabase.instance.client;
    final auth = client.auth;
    var session = auth.currentSession;

    if (session == null) {
      await client.realtime.setAuth(null);
      return false;
    }

    final expiresAt = session.expiresAt;
    final isExpired =
        expiresAt != null &&
        DateTime.fromMillisecondsSinceEpoch(
          expiresAt * 1000,
        ).isBefore(DateTime.now().add(const Duration(minutes: 1)));

    if (!isExpired) {
      await client.realtime.setAuth(session.accessToken);
      return true;
    }

    if (_isRefreshingSession) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      session = auth.currentSession;
      if (session == null) {
        await client.realtime.setAuth(null);
        return false;
      }

      await client.realtime.setAuth(session.accessToken);
      return true;
    }

    if ((session.refreshToken ?? '').isEmpty) {
      await client.realtime.setAuth(null);
      return false;
    }

    _isRefreshingSession = true;
    try {
      await auth.refreshSession();
      session = auth.currentSession;
      if (session == null) {
        await client.realtime.setAuth(null);
        return false;
      }

      await client.realtime.setAuth(session.accessToken);
      return true;
    } catch (_) {
      await client.realtime.setAuth(null);
      return false;
    } finally {
      _isRefreshingSession = false;
    }
  }

  Future<void> _subscribe(String userId) async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    await client.realtime.setAuth(session?.accessToken);

    _currentUserId = userId;
    _baselineNotificationIds.clear();
    _hasEstablishedBaseline = false;
    emit(NotificationLoading());
    await _notificationsSubscription?.cancel();
    _notificationsSubscription = SupabaseUtils.getNotificationsStream(userId)
        .listen(
          (notifications) {
            final unreadCount = _getNewUnreadNotificationCount(notifications);
            emit(
              NotificationLoaded(
                notifications: notifications,
                unreadCount: unreadCount,
              ),
            );
          },
          onError: (error) async {
            await _resetSubscription();
            final message = error.toString();
            if (message.contains('InvalidJWTToken')) {
              final refreshed = await _ensureValidSession();
              if (refreshed) {
                await client.removeAllChannels();
                await _subscribe(userId);
                return;
              }
              emit(
                NotificationError(
                  'Your session has expired. Please sign in again.',
                ),
              );
              return;
            }
            emit(NotificationError(message));
          },
        );
  }

  Future<void> _resetSubscription() async {
    await _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  Future<void> markAsRead(String notificationId) {
    return SupabaseUtils.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    final currentState = state;
    if (currentState is NotificationLoaded &&
        currentState.notifications.any((item) => item.isRead != true)) {
      final updatedNotifications = currentState.notifications
          .map(
            (item) => item.isRead == true
                ? item
                : AppNotification(
                    id: item.id,
                    title: item.title,
                    body: item.body,
                    createdAt: item.createdAt,
                    isRead: true,
                    type: item.type,
                    receiverId: item.receiverId,
                    bookingId: item.bookingId,
                    chatId: item.chatId,
                    senderId: item.senderId,
                  ),
          )
          .toList();

      _baselineNotificationIds
        ..clear()
        ..addAll(updatedNotifications.map((item) => item.id).whereType<String>());
      _hasEstablishedBaseline = true;

      emit(
        NotificationLoaded(notifications: updatedNotifications, unreadCount: 0),
      );
    }

    await SupabaseUtils.markAllNotificationsAsRead(userId);
  }

  int _getNewUnreadNotificationCount(List<AppNotification> notifications) {
    final currentIds = notifications.map((item) => item.id).whereType<String>().toSet();

    if (!_hasEstablishedBaseline) {
      _baselineNotificationIds
        ..clear()
        ..addAll(currentIds);
      _hasEstablishedBaseline = true;
      return 0;
    }

    return notifications.where((item) {
      final id = item.id;
      return id != null && item.isRead != true && !_baselineNotificationIds.contains(id);
    }).length;
  }

  @override
  Future<void> close() async {
    await _resetSubscription();
    return super.close();
  }
}
