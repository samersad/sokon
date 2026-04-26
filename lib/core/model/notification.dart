class AppNotification {
  static const String collectionName = "notifications";
  String? id;
  String? title;
  String? body;
  DateTime? createdAt;
  bool? isRead;
  String? type; // 'new_apartment', 'new_booking', 'booking_accepted', 'booking_cancelled', 'new_message'
  String? receiverId;
  String? bookingId;
  String? chatId;
  String? senderId;

  AppNotification({
    this.id,
    this.title,
    this.body,
    this.createdAt,
    this.isRead = false,
    this.type,
    this.receiverId,
    this.bookingId,
    this.chatId,
    this.senderId,
  });

  factory AppNotification.fromSupaBase(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id']?.toString(),
      title: data['title'],
      body: data['body'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      isRead: data['isRead'],
      type: data['type'],
      receiverId: data['receiverId'],
      bookingId: data['bookingId']?.toString(),
      chatId: data['chatId'],
      senderId: data['senderId'],
    );
  }

  Map<String, dynamic> toSupaBase() {
    final Map<String, dynamic> data = {
      'title': title,
      'body': body,
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'isRead': isRead,
      'type': type,
      'receiverId': receiverId,
      'bookingId': bookingId,
      'chatId': chatId,
      'senderId': senderId,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
