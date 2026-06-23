import '../../../../../core/model/BookingResponse.dart';
import '../../../../../core/model/booking.dart';

abstract class BookingRepository {
  Future<BookingResponse> addBooking(Booking booking);
  Future<List<BookingResponse>> getBookings(String userId);
  Future<List<BookingResponse>> getOwnerBookings(String ownerId);
  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  });
  Future<BookingResponse> updateBookingStatus({
    required String bookingId,
    required String status,
  });
  Future<BookingResponse> updateBookingStatusWithCapacity({
    required String bookingId,
    required String status,
  });
  Future<BookingResponse> rateBooking({
    required String bookingId,
    required int rating,
  });
}
