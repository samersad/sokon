import 'package:injectable/injectable.dart';
import '../../../../../core/model/booking.dart';
import '../../data_sources/remote/booking_remote_data_source.dart';
import '../booking_repository.dart';

@Injectable(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addBooking(Booking booking) =>
      remoteDataSource.addBooking(booking);

  @override
  Future<List<Booking>> getBookings(String userId) =>
      remoteDataSource.getBookings(userId);
}
