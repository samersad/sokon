import 'package:injectable/injectable.dart';
import '../../../../../core/model/BookingResponse.dart';
import '../../../../../core/model/booking.dart';
import '../../data_sources/remote/booking_remote_data_source.dart';
import '../booking_repository.dart';

@Injectable(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<BookingResponse> addBooking(Booking booking) =>
      remoteDataSource.addBooking(booking);

  @override
  Future<List<BookingResponse>> getBookings(String userId) =>
      remoteDataSource.getBookings(userId);

  @override
  Future<List<BookingResponse>> getOwnerBookings(String ownerId) =>
      remoteDataSource.getOwnerBookings(ownerId);

  @override
  Future<bool> hasActiveBookingForApartment({
    required String userId,
    required String apartmentId,
  }) {
    return remoteDataSource.hasActiveBookingForApartment(
      userId: userId,
      apartmentId: apartmentId,
    );
  }

  @override
  Future<BookingResponse> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    return remoteDataSource.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }

  @override
  Future<BookingResponse> updateBookingStatusWithCapacity({
    required String bookingId,
    required String status,
  }) {
    return remoteDataSource.updateBookingStatusWithCapacity(
      bookingId: bookingId,
      status: status,
    );
  }

  @override
  Future<BookingResponse> rateBooking({
    required String bookingId,
    required int rating,
  }) {
    return remoteDataSource.rateBooking(
      bookingId: bookingId,
      rating: rating,
    );
  }
}
