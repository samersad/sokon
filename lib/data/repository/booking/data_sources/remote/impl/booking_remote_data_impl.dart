import 'package:injectable/injectable.dart';
import '../../../../../../core/model/booking.dart';
import '../../../../../../supabase_utils.dart';

import '../booking_remote_data_source.dart';

@Injectable(as: BookingRemoteDataSource)
class BookingRemoteDataImpl implements BookingRemoteDataSource {
  @override
  Future<void> addBooking(Booking booking) async {
    return SupabaseUtils.addBookingToSupabase(booking);
  }

  @override
  Future<List<Booking>> getBookings(String userId) async {
    final List<dynamic> response = await SupabaseUtils.client
        .from('bookings')
        .select()
        .eq('clientId', userId);
    return response.map((e) => Booking.fromSupaBase(e as Map<String, dynamic>)).toList();
  }
}
