import '../../../../../core/model/booking.dart';

abstract class BookingRepository {
  Future<void> addBooking(Booking booking);
  Future<List<Booking>> getBookings(String userId);
  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  });
}
