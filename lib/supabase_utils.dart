// import 'dart:io';
// import 'package:sokon/core/model/apartment.dart';
// import 'package:sokon/core/model/booking.dart';
// import 'package:sokon/core/model/my_user.dart';
// import 'package:sokon/core/model/notification.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:path/path.dart' as p;
//
// class SupabaseUtils {
//   static SupabaseClient get client => Supabase.instance.client;
//
//   static const String notificationTypeNewApartment = 'new_apartment';
//   static const String notificationTypeNewBooking = 'new_booking';
//   static const String notificationTypeBookingAccepted = 'booking_accepted';
//   static const String notificationTypeBookingCancelled = 'booking_cancelled';
//   static const String notificationTypeBookingRejected = 'booking_rejected';
//   static const String notificationTypeNewMessage = 'new_message';
//
//   // --- STORAGE TOOLS ---
//
//   static Future<String?> uploadFile({
//     required File file,
//     required String bucket,
//     String? folder,
//   }) async {
//     try {
//       final fileName =
//           "${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}";
//       final path = folder != null ? "$folder/$fileName" : fileName;
//
//       await client.storage
//           .from(bucket)
//           .upload(
//             path,
//             file,
//             fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
//           );
//
//       return client.storage.from(bucket).getPublicUrl(path);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // --- DATABASE TOOLS ---
//
//   // Users
//   static Future<void> addUserToSupabase(MyUser myUser) async {
//     myUser.createdAt ??= DateTime.now();
//     await client.from('users').upsert(myUser.toSupaBase());
//   }
//
//   static Future<MyUser?> readUserFromSupabase(String id) async {
//     final response = await client
//         .from('users')
//         .select()
//         .eq('id', id)
//         .maybeSingle();
//     if (response == null) return null;
//     return MyUser.fromSupaBase(response);
//   }
//
//   static Future<void> updateUserFcmToken(String userId, String token) async {
//     try {
//       await client.from('users').update({'fcmToken': token}).eq('id', userId);
//     } catch (_) {
//       // Keep auth and startup working if the users table has not been migrated yet.
//     }
//   }
//
//   static Future<void> clearUserFcmToken(String userId) async {
//     try {
//       await client.from('users').update({'fcmToken': null}).eq('id', userId);
//     } catch (_) {
//       // Keep sign-out working if the users table has not been migrated yet.
//     }
//   }
//
//   // Apartments
//   static Future<void> addApartmentToSupabase(Apartment apartment) async {
//     apartment.createdAt = DateTime.now();
//     final response = await client
//         .from('apartments')
//         .insert(apartment.toSupaBase())
//         .select()
//         .single();
//     apartment.id = response['id'].toString();
//
//     await tryAddNotificationToSupabase(
//       AppNotification(
//         title: "New apartment listed",
//         body: _buildNewApartmentBody(apartment),
//         createdAt: DateTime.now(),
//         type: notificationTypeNewApartment,
//         isRead: false,
//       ),
//     );
//   }
//
//   static Future<void> deleteApartmentFromSupabase(String apartmentId) async {
//     await client.from('apartments').delete().eq('id', apartmentId);
//   }
//
//   static Future<void> updateApartmentInSupabase(Apartment apartment) async {
//     final data = apartment.toSupaBase();
//     data.remove('id');
//     await client.from('apartments').update(data).eq('id', apartment.id!);
//   }
//
//   static Future<List<Apartment>> getAllApartments() async {
//     final response = await client.from('apartments').select();
//     return response.map((e) => Apartment.fromSupaBase(e)).toList();
//   }
//
//   static Future<List<Apartment>> getOwnerApartments(String ownerId) async {
//     final response = await client
//         .from('apartments')
//         .select()
//         .eq('ownerId', ownerId);
//     return response.map((e) => Apartment.fromSupaBase(e)).toList();
//   }
//
//   // Bookings
//   static Future<void> addBookingToSupabase(Booking booking) async {
//     booking.createdAt = DateTime.now();
//     final response = await client
//         .from('bookings')
//         .insert(booking.toSupaBase())
//         .select()
//         .single();
//     booking.id = response['id'].toString();
//
//     await tryAddNotificationToSupabase(
//       AppNotification(
//         title: "Booking request received",
//         body: _buildBookingRequestBody(booking),
//         createdAt: DateTime.now(),
//         type: notificationTypeNewBooking,
//         isRead: false,
//         receiverId: booking.ownerId,
//         bookingId: booking.id,
//       ),
//     );
//
//     await sendBookingPushToOwner(booking);
//   }
//
//   static Future<void> updateBookingStatus({
//     required Booking booking,
//     required String status,
//     String? changedByName,
//   }) async {
//     final normalizedStatus = status.toLowerCase().trim();
//     final response = await client.rpc(
//       'update_booking_status_with_capacity',
//       params: {'p_booking_id': booking.id, 'p_status': normalizedStatus},
//     );
//
//     if (response is Map<String, dynamic>) {
//       booking.status = response['status'] as String? ?? normalizedStatus;
//     } else {
//       booking.status = normalizedStatus;
//     }
//
//     await notifyBookingStatusChange(
//       booking: booking,
//       status: normalizedStatus,
//       changedByName: changedByName,
//     );
//   }
//
//   static Future<Booking> rateBooking({
//     required Booking booking,
//     required int rating,
//   }) async {
//     final response = await client.rpc(
//       'rate_booking',
//       params: {'p_booking_id': booking.id, 'p_rating': rating},
//     );
//
//     final updatedBooking = Booking.fromSupaBase(
//       Map<String, dynamic>.from(response as Map),
//     );
//     booking.rating = updatedBooking.rating;
//     booking.ratedAt = updatedBooking.ratedAt;
//     return updatedBooking;
//   }
//
//   static Stream<List<Booking>> getBookingsStream(String userId) {
//     return client
//         .from('bookings')
//         .stream(primaryKey: ['id'])
//         .eq('clientId', userId)
//         .map((data) => data.map((e) => Booking.fromSupaBase(e)).toList());
//   }
//
//   static Stream<List<Booking>> getOwnerBookingsStream(String ownerId) {
//     return client
//         .from('bookings')
//         .stream(primaryKey: ['id'])
//         .eq('ownerId', ownerId)
//         .order('createdAt', ascending: false)
//         .map((data) {
//           final bookings = data.map((e) => Booking.fromSupaBase(e)).toList();
//           bookings.sort((a, b) {
//             final aTime = a.createdAt;
//             final bTime = b.createdAt;
//             if (aTime == null && bTime == null) return 0;
//             if (aTime == null) return 1;
//             if (bTime == null) return -1;
//             return bTime.compareTo(aTime);
//           });
//           return bookings;
//         });
//   }
//
//   // Notifications
//   static Future<void> addNotificationToSupabase(
//     AppNotification notification,
//   ) async {
//     final response = await client
//         .from('notifications')
//         .insert(notification.toSupaBase())
//         .select()
//         .single();
//     notification.id = response['id'].toString();
//   }
//
//   static Future<void> tryAddNotificationToSupabase(
//     AppNotification notification,
//   ) async {
//     try {
//       await addNotificationToSupabase(notification);
//     } catch (_) {
//       // Keep core flows working even if the notification schema is not migrated yet.
//     }
//   }
//
//   static Stream<List<AppNotification>> getNotificationsStream(String userId) {
//     return client
//         .from('notifications')
//         .stream(primaryKey: ['id'])
//         .eq('receiverId', userId)
//         .order('createdAt', ascending: false)
//         .map((data) {
//           final notifications = data
//               .map((e) => AppNotification.fromSupaBase(e))
//               .toList();
//           notifications.sort((a, b) {
//             final aTime = a.createdAt;
//             final bTime = b.createdAt;
//             if (aTime == null && bTime == null) return 0;
//             if (aTime == null) return 1;
//             if (bTime == null) return -1;
//             return bTime.compareTo(aTime);
//           });
//           return notifications;
//         });
//   }
//
//   static Future<void> markNotificationAsRead(String notificationId) async {
//     await client
//         .from('notifications')
//         .update({'isRead': true})
//         .eq('id', notificationId);
//   }
//
//   static Future<void> markAllNotificationsAsRead(String userId) async {
//     await client
//         .from('notifications')
//         .update({'isRead': true})
//         .eq('receiverId', userId)
//         .eq('isRead', false);
//   }
//
//   static Future<void> addChatNotificationToSupabase({
//     required String receiverId,
//     required String senderId,
//     required String senderName,
//     required String chatId,
//     required String message,
//   }) async {
//     final preview = _buildChatPreview(message);
//
//     await tryAddNotificationToSupabase(
//       AppNotification(
//         title: "New message from $senderName",
//         body: preview,
//         createdAt: DateTime.now(),
//         type: notificationTypeNewMessage,
//         isRead: false,
//         receiverId: receiverId,
//         chatId: chatId,
//         senderId: senderId,
//       ),
//     );
//
//     await sendChatPushToUser(
//       receiverId: receiverId,
//       senderId: senderId,
//       senderName: senderName,
//       chatId: chatId,
//       message: message,
//     );
//   }
//
//   static Future<void> addBookingStatusNotificationToSupabase({
//     required Booking booking,
//     required String status,
//     String? changedByName,
//   }) async {
//     final normalizedStatus = status.toLowerCase().trim();
//     final isAccepted =
//         normalizedStatus == 'accepted' || normalizedStatus == 'confirmed';
//     final isCancelled =
//         normalizedStatus == 'cancelled' || normalizedStatus == 'canceled';
//     final isRejected = normalizedStatus == 'rejected';
//
//     if (!isAccepted && !isCancelled && !isRejected) {
//       return;
//     }
//
//     final receiverId = booking.clientId;
//     if (receiverId == null || receiverId.isEmpty) {
//       return;
//     }
//
//     final title = isAccepted
//         ? "Booking approved"
//         : isCancelled
//         ? "Booking cancelled"
//         : "Booking rejected";
//     final body = isAccepted
//         ? _buildBookingAcceptedBody(booking, changedByName)
//         : isCancelled
//         ? _buildBookingCancelledBody(booking, changedByName)
//         : _buildBookingRejectedBody(booking, changedByName);
//     final type = isAccepted
//         ? notificationTypeBookingAccepted
//         : isCancelled
//         ? notificationTypeBookingCancelled
//         : notificationTypeBookingRejected;
//
//     await tryAddNotificationToSupabase(
//       AppNotification(
//         title: title,
//         body: body,
//         createdAt: DateTime.now(),
//         type: type,
//         isRead: false,
//         receiverId: receiverId,
//         bookingId: booking.id,
//       ),
//     );
//
//     await sendBookingStatusPushToUser(
//       receiverId: receiverId,
//       bookingId: booking.id,
//       title: title,
//       body: body,
//       type: type,
//     );
//   }
//
//   static String _buildNewApartmentBody(Apartment apartment) {
//     final ownerName = apartment.ownerName?.trim();
//     final apartmentName = apartment.name?.trim();
//     if (ownerName != null &&
//         ownerName.isNotEmpty &&
//         apartmentName != null &&
//         apartmentName.isNotEmpty) {
//       return "$ownerName listed $apartmentName for rent.";
//     }
//     if (apartmentName != null && apartmentName.isNotEmpty) {
//       return "A new apartment, $apartmentName, is now available.";
//     }
//     return "A new apartment is now available.";
//   }
//
//   static String _buildBookingRequestBody(Booking booking) {
//     final clientName = booking.clientName?.trim();
//     final apartmentName = booking.apartmentName?.trim();
//     final ownerName = booking.ownerName?.trim();
//     final peopleCount = booking.peopleCount ?? 1;
//
//     if (clientName != null &&
//         clientName.isNotEmpty &&
//         apartmentName != null &&
//         apartmentName.isNotEmpty &&
//         ownerName != null &&
//         ownerName.isNotEmpty) {
//       return "$clientName requested $apartmentName for $peopleCount ${peopleCount == 1 ? 'person' : 'people'} with $ownerName.";
//     }
//
//     if (clientName != null &&
//         clientName.isNotEmpty &&
//         apartmentName != null &&
//         apartmentName.isNotEmpty) {
//       return "$clientName submitted a booking request for $apartmentName for $peopleCount ${peopleCount == 1 ? 'person' : 'people'}.";
//     }
//
//     return "A new booking request has been submitted.";
//   }
//
//   static String _buildBookingAcceptedBody(
//     Booking booking,
//     String? changedByName,
//   ) {
//     final apartmentName = booking.apartmentName?.trim();
//     final managerName = changedByName?.trim() ?? booking.ownerName?.trim();
//     if (apartmentName != null &&
//         apartmentName.isNotEmpty &&
//         managerName != null &&
//         managerName.isNotEmpty) {
//       return "$managerName approved your booking for $apartmentName.";
//     }
//     if (apartmentName != null && apartmentName.isNotEmpty) {
//       return "Your booking for $apartmentName has been approved.";
//     }
//     return "Your booking request has been approved.";
//   }
//
//   static String _buildBookingCancelledBody(
//     Booking booking,
//     String? changedByName,
//   ) {
//     final apartmentName = booking.apartmentName?.trim();
//     final managerName = changedByName?.trim() ?? booking.ownerName?.trim();
//     if (apartmentName != null &&
//         apartmentName.isNotEmpty &&
//         managerName != null &&
//         managerName.isNotEmpty) {
//       return "$managerName cancelled the booking for $apartmentName.";
//     }
//     if (apartmentName != null && apartmentName.isNotEmpty) {
//       return "Your booking for $apartmentName has been cancelled.";
//     }
//     return "Your booking has been cancelled.";
//   }
//
//   static String _buildBookingRejectedBody(
//     Booking booking,
//     String? changedByName,
//   ) {
//     final apartmentName = booking.apartmentName?.trim();
//     final managerName = changedByName?.trim() ?? booking.ownerName?.trim();
//     if (apartmentName != null &&
//         apartmentName.isNotEmpty &&
//         managerName != null &&
//         managerName.isNotEmpty) {
//       return "$managerName rejected the booking request for $apartmentName.";
//     }
//     if (apartmentName != null && apartmentName.isNotEmpty) {
//       return "Your booking request for $apartmentName was rejected.";
//     }
//     return "Your booking request was rejected.";
//   }
//
//   static String _buildChatPreview(String message) {
//     final normalized = message.trim();
//     if (normalized.isEmpty) {
//       return "You have a new message.";
//     }
//
//     return normalized.length > 80
//         ? "${normalized.substring(0, 80)}..."
//         : normalized;
//   }
//
//   static Future<void> notifyBookingStatusChange({
//     required Booking booking,
//     required String status,
//     String? changedByName,
//   }) {
//     return addBookingStatusNotificationToSupabase(
//       booking: booking,
//       status: status,
//       changedByName: changedByName,
//     );
//   }
//
//   static Future<void> sendBookingPushToOwner(Booking booking) async {
//     try {
//       final peopleCount = booking.peopleCount ?? 1;
//       await client.functions.invoke(
//         'send-booking-notification',
//         body: {
//           'ownerId': booking.ownerId,
//           'bookingId': booking.id,
//           'title': 'New Booking Request',
//           'body':
//               'Client ${booking.clientName} requested ${booking.apartmentName} for $peopleCount ${peopleCount == 1 ? 'person' : 'people'}',
//           'type': 'new_booking',
//         },
//       );
//     } catch (_) {
//       // Keep booking flow working even if push delivery is unavailable.
//     }
//   }
//
//   static Future<void> sendChatPushToUser({
//     required String receiverId,
//     required String senderId,
//     required String senderName,
//     required String chatId,
//     required String message,
//   }) async {
//     try {
//       await client.functions.invoke(
//         'send-chat-notification',
//         body: {
//           'receiverId': receiverId,
//           'senderId': senderId,
//           'chatId': chatId,
//           'title': 'New message from $senderName',
//           'body': _buildChatPreview(message),
//           'type': notificationTypeNewMessage,
//         },
//       );
//     } catch (_) {
//       // Keep chat flow working even if push delivery is unavailable.
//     }
//   }
//
//   static Future<void> sendBookingStatusPushToUser({
//     required String receiverId,
//     required String? bookingId,
//     required String title,
//     required String body,
//     required String type,
//   }) async {
//     try {
//       await client.functions.invoke(
//         'send-booking-status-notification',
//         body: {
//           'receiverId': receiverId,
//           'bookingId': bookingId,
//           'title': title,
//           'body': body,
//           'type': type,
//         },
//       );
//     } catch (_) {
//       // Keep booking status flow working even if push delivery is unavailable.
//     }
//   }
// }
