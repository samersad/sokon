import '../../../../../core/model/booking.dart';

abstract class BookingRemoteDataSource {
  Future<void> addBooking(Booking booking);
  Future<List<Booking>> getBookings(String userId);
  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  });
  Future<void> updateBookingStatus({
    required Booking booking,
    required String status,
    String? changedByName,
  });
}
