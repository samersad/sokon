import 'package:dio/dio.dart';
import 'package:sokon/api/end_points.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/model/BookingResponse.dart';
import 'package:sokon/core/model/LogoutResponse.dart';
import 'package:sokon/core/model/notification.dart';
import 'package:sokon/core/model/RegisterResponse.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/model/booking.dart';

import 'api_constants.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
    ),
  );

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarId,
    String? college,
    String? gender,
    String role = 'client',
  }) async {
    try {
      final response = await dio.post(
        EndPoints.registerApi,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "phoneNumber": phone,
          "photoUrl": null,
          "college": college,
          "gender": gender,
          "role": role,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.loginApi,
        data: {
          "email": email,
          "password": password,
        },
      );

      return LoginResponse.fromJson(response.data); // ← الصحيsح
    } on DioException catch (e) {
      final errorMessage = e.response?.data["message"] ?? "Unknown Error";

      if (e.response != null) {
        throw Exception(errorMessage);
      } else {
        throw Exception("Network Error");
      }
    }
  }

  Future<RegisterUser> updateUser({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
    String? college,
    String? gender,
    String? photoUrl,
    dynamic fcmToken,
  }) async {
    try {
      final token = SharedPrefsHelper.getData(key: "token")?.toString();
      final response = await dio.patch(
        EndPoints.userApi(userId),
        data: {
          "name": name,
          "email": email,
          "college": college,
          "phoneNumber": phoneNumber,
          "gender": gender,
          "role": role,
          "photoUrl": photoUrl,
          "fcmToken": fcmToken,
        },
        options: token == null || token.isEmpty
            ? null
            : Options(headers: {"Authorization": "Bearer $token"}),
      );

      return RegisterUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update user failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<RegisterUser> upsertUser(RegisterUser user) async {
    try {
      final response = await dio.post(
        EndPoints.usersApi,
        data: user.toSupaBase(),
        options: _requiredAuthOptions(),
      );

      return RegisterUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Save user failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<RegisterUser> getUser(String userId) async {
    try {
      final response = await dio.get(
        EndPoints.userApi(userId),
        options: _authOptions(),
      );
      return RegisterUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get user failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<RegisterResponse> exchangeSession(String token) async {
    try {
      final response = await dio.post(
        EndPoints.authExchangeApi,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Session exchange failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<String?> requestPasswordReset(String email) async {
    try {
      final response = await dio.post(
        EndPoints.passwordResetApi,
        data: {'email': email},
      );
      final data = response.data;
      if (data is Map) {
        return data['resetToken']?.toString();
      }
      return null;
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Request password reset failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<String> verifyResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.passwordResetVerifyOtpApi,
        data: {'email': email, 'otp': otp},
      );
      final data = response.data;
      if (data is Map && data['resetToken'] != null) {
        return data['resetToken'].toString();
      }
      throw Exception("Invalid response from server");
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "OTP verification failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<RegisterResponse> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.passwordResetConfirmApi,
        data: {'token': token, 'password': password},
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Confirm password reset failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<RegisterUser> updatePassword(String password) async {
    try {
      final response = await dio.patch(
        EndPoints.passwordApi,
        data: {'password': password},
        options: _requiredAuthOptions(),
      );
      return RegisterUser.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update password failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final token = SharedPrefsHelper.getData(key: "token")?.toString();
      final response = await dio.post(
        EndPoints.logoutApi,
        options: token == null || token.isEmpty
            ? null
            : Options(headers: {"Authorization": "Bearer $token"}),
      );

      final logoutResponse = LogoutResponse.fromJson(response.data);
      if (!logoutResponse.signedOut) {
        throw Exception("Logout failed");
      }
      return logoutResponse;
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Logout failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> deleteAccount({String? password}) async {
    try {
      final data = <String, dynamic>{};
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      await dio.delete(
        EndPoints.deleteAccountApi,
        data: data,
        options: _requiredAuthOptions(),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Delete account failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<ApartmentResponse> addApartment(Apartment apartment) async {
    try {
      final response = await dio.post(
        EndPoints.apartmentsApi,
        data: _apartmentPayload(apartment),
        options: _requiredAuthOptions(),
      );

      return ApartmentResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Add apartment failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<ApartmentResponse> updateApartment(Apartment apartment) async {
    try {
      final apartmentId = apartment.id;
      if (apartmentId == null || apartmentId.isEmpty) {
        throw Exception("Apartment id is required.");
      }

      final response = await dio.patch(
        EndPoints.apartmentApi(apartmentId),
        data: _apartmentPayload(apartment),
        options: _requiredAuthOptions(),
      );

      return ApartmentResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update apartment failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<ApartmentResponse> setApartmentVerification({
    required String apartmentId,
    required bool verified,
  }) async {
    try {
      final response = await dio.patch(
        EndPoints.apartmentVerifyApi(apartmentId),
        data: {'verified': verified},
        options: _requiredAuthOptions(),
      );
      return ApartmentResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update apartment verification failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    try {
      await dio.delete(
        EndPoints.apartmentApi(apartmentId),
        options: _requiredAuthOptions(),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Delete apartment failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<ApartmentResponse>> getAllApartments() async {
    try {
      final response = await dio.get(
        EndPoints.apartmentsApi,
        options: _authOptions(),
      );
      return _parseApartmentList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get apartments failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<ApartmentResponse>> getApartmentsByOwner(String ownerId) async {
    final apartments = await getAllApartments();
    return apartments.where((apartment) => apartment.ownerId == ownerId).toList();
  }

  Future<List<ApartmentResponse>> searchApartments(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return getAllApartments();
    }

    try {
      final response = await dio.get(
        EndPoints.apartmentsSearchApi,
        queryParameters: {'query': normalizedQuery},
        options: _authOptions(),
      );
      return _parseApartmentList(response.data);
    } on DioException catch (_) {
      final apartments = await getAllApartments();
      return apartments
          .where((apartment) => _matchesApartmentSearch(apartment, normalizedQuery))
          .toList();
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<BookingResponse> addBooking(Booking booking) async {
    try {
      final response = await dio.post(
        EndPoints.bookingsApi,
        data: _bookingPayload(booking),
        options: _requiredAuthOptions(),
      );
      return BookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Add booking failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<BookingResponse>> getBookingsByClient(String userId) async {
    return _getBookings(queryParameters: {'clientId': userId});
  }

  Future<List<BookingResponse>> getBookingsByOwner(String userId) async {
    return _getBookings(queryParameters: {'ownerId': userId});
  }

  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  }) async {
    try {
      final response = await dio.get(
        EndPoints.bookingActiveCheckApi,
        queryParameters: {
          'userId': userId,
          'apartmentId': apartmentId,
        },
        options: _requiredAuthOptions(),
      );
      final data = response.data;
      if (data is bool) return data;
      if (data is Map) {
        return data['hasActiveBooking'] == true ||
            data['active'] == true ||
            data['exists'] == true;
      }
      return false;
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Check active booking failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<BookingResponse> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await dio.patch(
        EndPoints.bookingStatusApi(bookingId),
        data: {'status': status},
        options: _requiredAuthOptions(),
      );
      return BookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update booking status failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<BookingResponse> updateBookingStatusWithCapacity({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.updateBookingStatusWithCapacityApi,
        data: {
          'bookingId': bookingId,
          'booking_id': bookingId,
          'p_booking_id': bookingId,
          'status': status,
          'new_status': status,
          'p_status': status,
        },
        options: _requiredAuthOptions(),
      );
      return BookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Update booking status failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<BookingResponse> rateBooking({
    required String bookingId,
    required int rating,
  }) async {
    try {
      final response = await dio.post(
        EndPoints.bookingRatingApi(bookingId),
        data: {'rating': rating},
        options: _requiredAuthOptions(),
      );
      return BookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Rate booking failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getChats(String userId) async {
    try {
      final response = await dio.get(
        EndPoints.chatsApi,
        queryParameters: {'userId': userId},
        options: _requiredAuthOptions(),
      );
      return _parseMapList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get chats failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<Map<String, dynamic>> upsertChat(
    Map<String, dynamic> chatData,
  ) async {
    try {
      final response = await dio.post(
        EndPoints.chatsApi,
        data: chatData,
        options: _requiredAuthOptions(),
      );
      return _parseMap(response.data, keys: const ['chat', 'data', 'item']);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Save chat failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<Map<String, dynamic>> getChatById(String chatId) async {
    try {
      final response = await dio.get(
        EndPoints.chatApi(chatId),
        options: _requiredAuthOptions(),
      );
      return _parseMap(response.data, keys: const ['chat', 'data', 'item']);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get chat failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await dio.delete(
        EndPoints.chatApi(chatId),
        options: _requiredAuthOptions(),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Delete chat failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    try {
      final response = await dio.get(
        EndPoints.chatMessagesApi(chatId),
        options: _requiredAuthOptions(),
      );
      return _parseMapList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get messages failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    try {
      final response = await dio.post(
        EndPoints.chatMessagesApi(chatId),
        data: messageData,
        options: _requiredAuthOptions(),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Send message failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await dio.delete(
        EndPoints.messageApi(messageId),
        options: _requiredAuthOptions(),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Delete message failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final response = await dio.get(
        EndPoints.notificationsApi,
        queryParameters: {'receiverId': userId},
        options: _requiredAuthOptions(),
      );
      return _parseNotificationList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get notifications failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await dio.patch(
        EndPoints.notificationReadApi(notificationId),
        options: _requiredAuthOptions(),
      );
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Mark notification read failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Future<List<AppNotification>> markAllNotificationsAsRead(String userId) async {
    try {
      final response = await dio.patch(
        EndPoints.notificationsReadAllApi(userId),
        options: _requiredAuthOptions(),
      );
      return _parseNotificationList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Mark all notifications read failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  Options? _authOptions() {
    final token = SharedPrefsHelper.getData(key: "token")?.toString();
    if (token == null || token.isEmpty) {
      return null;
    }
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  Options _requiredAuthOptions() {
    final token = SharedPrefsHelper.getData(key: "token")?.toString();
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token is required.");
    }
    return Options(headers: {"Authorization": "Bearer $token"});
  }

  List<ApartmentResponse> _parseApartmentList(dynamic data) {
    final dynamic listData = data is Map
        ? data['apartments'] ?? data['data'] ?? data['items']
        : data;
    if (listData is! List) {
      return [];
    }
    return listData
        .map((item) => ApartmentResponse.fromJson(item))
        .toList();
  }

  bool _matchesApartmentSearch(ApartmentResponse apartment, String query) {
    final searchLower = query.toLowerCase();
    final fields = [
      apartment.name,
      apartment.description,
      apartment.address,
      apartment.locationAddress,
      apartment.city,
      apartment.district,
    ];

    return fields.any(
      (field) => field != null && field.toLowerCase().contains(searchLower),
    );
  }

  Future<List<BookingResponse>> _getBookings({
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await dio.get(
        EndPoints.bookingsApi,
        queryParameters: queryParameters,
        options: _requiredAuthOptions(),
      );
      return _parseBookingList(response.data);
    } on DioException catch (e) {
      final serverMessage = e.response?.data?['message'];
      throw Exception(serverMessage ?? "Get bookings failed");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  List<BookingResponse> _parseBookingList(dynamic data) {
    final dynamic listData = data is Map
        ? data['bookings'] ?? data['data'] ?? data['items']
        : data;
    if (listData is! List) {
      return [];
    }
    return listData.map((item) => BookingResponse.fromJson(item)).toList();
  }

  List<Map<String, dynamic>> _parseMapList(dynamic data) {
    final dynamic listData = data is Map
        ? data['chats'] ?? data['messages'] ?? data['data'] ?? data['items']
        : data;
    if (listData is! List) {
      return [];
    }
    return listData
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Map<String, dynamic> _parseMap(
    dynamic data, {
    required List<String> keys,
  }) {
    if (data is! Map) {
      return {};
    }
    final map = Map<String, dynamic>.from(data);
    for (final key in keys) {
      final value = map[key];
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
    }
    return map;
  }

  List<AppNotification> _parseNotificationList(dynamic data) {
    final dynamic listData = data is Map
        ? data['notifications'] ?? data['data'] ?? data['items']
        : data;
    if (listData is! List) {
      return [];
    }
    return listData
        .map((item) => AppNotification.fromSupaBase(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Map<String, dynamic> _apartmentPayload(Apartment apartment) {
    return {
      'name': apartment.name,
      'description': apartment.description,
      'price': apartment.price,
      'images': apartment.images ?? [],
      'video_url': apartment.videoUrl,
      'bedrooms': apartment.bedrooms,
      'bathrooms': apartment.bathrooms,
      'living_rooms': apartment.livingRooms,
      'floor': apartment.floor ?? 1,
      'max_people': apartment.maxPeople,
      'available_people': apartment.availablePeople,
      'address': apartment.address,
      'city': apartment.city ?? 'Assuit',
      'district': apartment.district,
      'locationAddress': apartment.locationAddress,
      'lat': apartment.lat,
      'lng': apartment.lng,
      'ownerId': apartment.ownerId,
      'ownerName': apartment.ownerName,
      'ownerPhotoUrl': apartment.ownerPhotoUrl,
      'verified': apartment.verified ?? false,
      'rating_sum': apartment.ratingSum ?? 0,
      'rating_count': apartment.ratingCount ?? 0,
      'rating_average': apartment.ratingAverage ?? 0,
      if (apartment.id != null) 'id': apartment.id,
      if (apartment.createdAt != null)
        'createdAt': apartment.createdAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> _bookingPayload(Booking booking) {
    return {
      'apartmentId': booking.apartmentId,
      'apartmentName': booking.apartmentName,
      'apartmentAddress': booking.apartmentAddress,
      'apartmentImage': booking.apartmentImage,
      'clientId': booking.clientId,
      'clientName': booking.clientName,
      'ownerId': booking.ownerId,
      'ownerName': booking.ownerName,
      'startDate': booking.startDate?.toIso8601String(),
      'endDate': booking.endDate?.toIso8601String(),
      'totalPrice': booking.totalPrice,
      'people_count': booking.peopleCount,
      'rating': booking.rating,
      'rated_at': booking.ratedAt?.toIso8601String(),
      'status': booking.status ?? 'pending',
      if (booking.createdAt != null)
        'createdAt': booking.createdAt!.toIso8601String(),
      if (booking.id != null) 'id': booking.id,
    };
  }
}
