import 'package:sokon/core/model/notification.dart';

abstract class NotificationStates {}

class NotificationInitial extends NotificationStates {}

class NotificationLoading extends NotificationStates {}

class NotificationLoaded extends NotificationStates {
  final List<AppNotification> notifications;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationError extends NotificationStates {
  final String message;

  NotificationError(this.message);
}
