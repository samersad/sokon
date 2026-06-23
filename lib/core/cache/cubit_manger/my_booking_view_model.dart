import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../api/api_service .dart';
import '../../model/booking.dart';
import 'my_booking_states.dart';

@injectable
class MyBookingViewModel extends Cubit<MyBookingState> {
  MyBookingViewModel() : super(MyBookingInitial());
  final ApiService _apiService = ApiService();

  List<Booking> bookingList = [];

  Future<void> getBookings(String userId) async {
    emit(MyBookingLoading());
    try {
      final bookings = await _apiService.getBookingsByClient(userId);
      bookingList = bookings
          .map((booking) => Booking.fromSupaBase(booking.toJson()))
          .toList();
      emit(MyBookingLoaded(bookingList));
    } catch (e) {
      emit(MyBookingError(e.toString()));
    }
  }
}
