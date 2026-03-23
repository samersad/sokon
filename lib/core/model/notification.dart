import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  static const String collectionName = "notifications";
  String? id;
  String? title;
  String? body;
  DateTime? createdAt;
  bool? isRead;
  String? type; // 'new_apartment', 'new_booking'

  AppNotification({
    this.id,
    this.title,
    this.body,
    this.createdAt,
    this.isRead = false,
    this.type,
  });

  AppNotification.fromFireStore(Map<String, dynamic> data)
      : this(
          id: data['id'],
          title: data['title'],
          body: data['body'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          isRead: data['isRead'],
          type: data['type'],
        );

  Map<String, dynamic> toFireStore() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'isRead': isRead,
      'type': type,
    };
  }
}
