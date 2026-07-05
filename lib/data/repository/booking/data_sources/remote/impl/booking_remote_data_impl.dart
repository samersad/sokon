import 'package:injectable/injectable.dart';
import 'package:sokon/api/api_service .dart';
import '../../../../../../core/model/BookingResponse.dart';
import '../../../../../../core/model/booking.dart';

import '../booking_remote_data_source.dart';

@Injectable(as: BookingRemoteDataSource)
class BookingRemoteDataImpl implements BookingRemoteDataSource {
  final ApiService _apiService = ApiService();

  @override
  Future<BookingResponse> addBooking(Booking booking) async {
    return _apiService.addBooking(booking);
  }

  @override
  Future<List<BookingResponse>> getBookings(String userId) async {
    return _apiService.getBookingsByClient(userId);
  }

  @override
  Future<List<BookingResponse>> getOwnerBookings(String ownerId) async {
    return _apiService.getBookingsByOwner(ownerId);
  }

  @override
  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  }) async {
    return _apiService.hasActiveBookingForApartment(
      userId: userId,
      apartmentId: apartmentId,
    );
  }

  @override
  Future<BookingResponse> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    return _apiService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }

  @override
  Future<BookingResponse> updateBookingStatusWithCapacity({
    required String bookingId,
    required String status,
  }) {
    return _apiService.updateBookingStatusWithCapacity(
      bookingId: bookingId,
      status: status,
    );
  }

  @override
  Future<BookingResponse> rateBooking({
    required String bookingId,
    required int rating,
  }) {
    return _apiService.rateBooking(
      bookingId: bookingId,
      rating: rating,
    );
  }
}
