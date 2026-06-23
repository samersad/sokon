import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/api/api_service .dart';
import 'package:sokon/core/model/notification.dart';

import 'notification_states.dart';

@lazySingleton
class NotificationViewModel extends Cubit<NotificationStates> {
  NotificationViewModel() : super(NotificationInitial());

  final ApiService _apiService = ApiService();
  Timer? _pollTimer;
  String? _currentUserId;
  final Set<String> _baselineNotificationIds = <String>{};
  bool _hasEstablishedBaseline = false;

  Future<void> listenToNotifications(String userId) async {
    if (_currentUserId == userId && _pollTimer != null) {
      return;
    }

    _currentUserId = userId;
    _baselineNotificationIds.clear();
    _hasEstablishedBaseline = false;
    emit(NotificationLoading());
    await _loadNotifications(userId);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadNotifications(userId),
    );
  }

  Future<void> _loadNotifications(String userId) async {
    try {
      final notifications = await _apiService.getNotifications(userId);
      final unreadCount = _getNewUnreadNotificationCount(notifications);
      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) {
    return _apiService.markNotificationAsRead(notificationId);
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

    await _apiService.markAllNotificationsAsRead(userId);
  }

  int _getNewUnreadNotificationCount(List<AppNotification> notifications) {
    final currentIds =
        notifications.map((item) => item.id).whereType<String>().toSet();

    if (!_hasEstablishedBaseline) {
      _baselineNotificationIds
        ..clear()
        ..addAll(currentIds);
      _hasEstablishedBaseline = true;
      return 0;
    }

    return notifications.where((item) {
      final id = item.id;
      return id != null &&
          item.isRead != true &&
          !_baselineNotificationIds.contains(id);
    }).length;
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    return super.close();
  }
}
