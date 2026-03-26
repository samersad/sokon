import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../core/model/booking.dart';
import '../../../../../../../data/repository/booking/repository/booking_repository.dart';
import 'my_bookings_states.dart';

@injectable
class MyBookingsViewModel extends Cubit<MyBookingsStates> {
  final BookingRepository bookingRepository;
  MyBookingsViewModel(this.bookingRepository) : super(MyBookingsInitial());

  List<Booking> bookingsList = [];

  Future<void> getMyBookings(String userId) async {
    emit(MyBookingsLoading());
    try {
      final list = await bookingRepository.getBookings(userId);
      bookingsList = list;
      emit(MyBookingsSuccess(bookingsList));
    } catch (e) {
      emit(MyBookingsError(e.toString()));
    }
  }
}
