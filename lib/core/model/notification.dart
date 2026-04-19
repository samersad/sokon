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

  factory AppNotification.fromSupaBase(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id']?.toString(),
      title: data['title'],
      body: data['body'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      isRead: data['isRead'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toSupaBase() {
    final Map<String, dynamic> data = {
      'title': title,
      'body': body,
      'createdAt': createdAt?.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
