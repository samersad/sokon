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

  Future<void> listenToNotifications(String userId) async {
    if (_currentUserId == userId && _pollTimer != null) {
      return;
    }

    _currentUserId = userId;
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
      final unreadCount = notifications.where((n) => n.isRead != true).length;
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

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedNotifications = currentState.notifications.map((item) {
          if (item.id == notificationId) {
            return AppNotification(
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
            );
          }
          return item;
        }).toList();

        final newUnreadCount = updatedNotifications.where((n) => n.isRead != true).length;
        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ));
      }
    } catch (e) {
      // Keep state as is on error
    }
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

      emit(
        NotificationLoaded(notifications: updatedNotifications, unreadCount: 0),
      );
    }

    await _apiService.markAllNotificationsAsRead(userId);
  }

  Future<void> markChatNotificationsAsRead(String chatId) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      final chatNotifications = currentState.notifications
          .where((n) => n.chatId == chatId && n.isRead != true)
          .toList();

      if (chatNotifications.isEmpty) return;

      for (final n in chatNotifications) {
        if (n.id != null) {
          await _apiService.markNotificationAsRead(n.id!);
        }
      }

      final updatedNotifications = currentState.notifications.map((item) {
        if (item.chatId == chatId && item.isRead != true) {
          return AppNotification(
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
          );
        }
        return item;
      }).toList();

      final newUnreadCount = updatedNotifications.where((n) => n.isRead != true).length;
      emit(NotificationLoaded(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    }
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    return super.close();
  }
}
