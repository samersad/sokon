import 'dart:io';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/model/my_user.dart';
import 'package:sokon/core/model/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class SupabaseUtils {
  static SupabaseClient get client => Supabase.instance.client;

  // --- STORAGE TOOLS ---

  static Future<String?> uploadFile({
    required File file,
    required String bucket,
    String? folder,
  }) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}";
      final path = folder != null ? "$folder/$fileName" : fileName;

      await client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  // --- DATABASE TOOLS ---

  // Users
  static Future<void> addUserToSupabase(MyUser myUser) async {
    myUser.createdAt ??= DateTime.now();
    await client.from('users').upsert(myUser.toSupaBase());
  }

  static Future<MyUser?> readUserFromSupabase(String id) async {
    final response = await client.from('users').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return MyUser.fromSupaBase(response);
  }

  // Apartments
  static Future<void> addApartmentToSupabase(Apartment apartment) async {
    apartment.createdAt = DateTime.now();
    final response = await client.from('apartments').insert(apartment.toSupaBase()).select().single();
    apartment.id = response['id'].toString();

    await tryAddNotificationToSupabase(AppNotification(
      title: "New Apartment Added",
      body: "Owner ${apartment.ownerName} added a new apartment: ${apartment.name}",
      createdAt: DateTime.now(),
      type: 'new_apartment',
      isRead: false,
    ));
  }

  static Future<void> deleteApartmentFromSupabase(String apartmentId) async {
    await client.from('apartments').delete().eq('id', apartmentId);
  }

  static Future<void> updateApartmentInSupabase(Apartment apartment) async {
    final data = apartment.toSupaBase();
    data.remove('id');
    await client.from('apartments').update(data).eq('id', apartment.id!);
  }

  static Future<List<Apartment>> getAllApartments() async {
    final response = await client.from('apartments').select();
    return response.map((e) => Apartment.fromSupaBase(e)).toList();
  }

  static Future<List<Apartment>> getOwnerApartments(String ownerId) async {
    final response = await client.from('apartments').select().eq('ownerId', ownerId);
    return response.map((e) => Apartment.fromSupaBase(e)).toList();
  }

  // Bookings
  static Future<void> addBookingToSupabase(Booking booking) async {
    booking.createdAt = DateTime.now();
    final response = await client.from('bookings').insert(booking.toSupaBase()).select().single();
    booking.id = response['id'].toString();

    await tryAddNotificationToSupabase(AppNotification(
      title: "New Booking Request",
      body: "Client ${booking.clientName} booked ${booking.apartmentName} from ${booking.ownerName}",
      createdAt: DateTime.now(),
      type: 'new_booking',
      isRead: false,
      receiverId: booking.ownerId,
      bookingId: booking.id,
    ));
  }

  static Stream<List<Booking>> getBookingsStream(String userId) {
    return client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('clientId', userId)
        .map((data) => data.map((e) => Booking.fromSupaBase(e)).toList());
  }

  // Notifications
  static Future<void> addNotificationToSupabase(AppNotification notification) async {
    final response = await client.from('notifications').insert(notification.toSupaBase()).select().single();
    notification.id = response['id'].toString();
  }

  static Future<void> tryAddNotificationToSupabase(AppNotification notification) async {
    try {
      await addNotificationToSupabase(notification);
    } catch (_) {
      // Keep core flows working even if the notification schema is not migrated yet.
    }
  }

  static Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('receiverId', userId)
        .order('createdAt', ascending: false)
        .map((data) {
          final notifications =
              data.map((e) => AppNotification.fromSupaBase(e)).toList();
          notifications.sort((a, b) {
            final aTime = a.createdAt;
            final bTime = b.createdAt;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          return notifications;
        });
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'isRead': true})
        .eq('id', notificationId);
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    await client
        .from('notifications')
        .update({'isRead': true})
        .eq('receiverId', userId)
        .eq('isRead', false);
  }

  static Future<void> addChatNotificationToSupabase({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String chatId,
    required String message,
  }) async {
    final preview = message.length > 60 ? "${message.substring(0, 60)}..." : message;

    await tryAddNotificationToSupabase(
      AppNotification(
        title: senderName,
        body: preview,
        createdAt: DateTime.now(),
        type: 'new_message',
        isRead: false,
        receiverId: receiverId,
        chatId: chatId,
        senderId: senderId,
      ),
    );
  }
}
