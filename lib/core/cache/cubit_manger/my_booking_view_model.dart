import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../supabase_utils.dart';
import '../../model/booking.dart';
import 'my_booking_states.dart';

@injectable
class MyBookingViewModel extends Cubit<MyBookingState> {
  MyBookingViewModel() : super(MyBookingInitial());

  List<Booking> bookingList = [];

  Future<void> getBookings(String userId) async {
    emit(MyBookingLoading());
    try {
      SupabaseUtils.getBookingsStream(userId).listen((bookings) {
        bookingList = bookings;
        emit(MyBookingLoaded(bookingList));
      });
    } catch (e) {
      emit(MyBookingError(e.toString()));
    }
  }
}
