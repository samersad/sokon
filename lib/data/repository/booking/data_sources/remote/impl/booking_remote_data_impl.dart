import 'package:injectable/injectable.dart';
import '../../../../../../core/model/booking.dart';
import '../../../../../../firebase_utils.dart';

import '../booking_remote_data_source.dart';

@Injectable(as: BookingRemoteDataSource)
class BookingRemoteDataImpl implements BookingRemoteDataSource {
  @override
  Future<void> addBooking(Booking booking) async {
    return FireBaseUtils.addBookingToFirestore(booking);
  }

  @override
  Future<List<Booking>> getBookings(String userId) async {
    var querySnapshot = await FireBaseUtils.getBookingCollections()
        .where('clientId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
