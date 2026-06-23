import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/data/repository/booking/data_sources/remote/impl/booking_remote_data_impl.dart';
import 'package:sokon/data/repository/booking/repository/booking_repository.dart';
import 'package:sokon/data/repository/booking/repository/impl/booking_repository_impl.dart';

import 'my_bookings_states.dart';

@injectable
class MyBookingsViewModel extends Cubit<MyBookingsStates> {
  MyBookingsViewModel() : super(MyBookingsInitial());

  final BookingRepository _bookingRepository =
      BookingRepositoryImpl(BookingRemoteDataImpl());

  Future<void> getMyBookings(String userId) async {
    emit(MyBookingsLoading());
    try {
      final bookings = await _bookingRepository.getBookings(userId);
      emit(MyBookingsSuccess(bookings));
    } catch (e) {
      emit(MyBookingsError(e.toString()));
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    if (bookingId.isEmpty) {
      throw Exception("Booking id is required.");
    }
    await _bookingRepository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }

  Future<void> rateBooking({
    required String bookingId,
    required int rating,
  }) async {
    if (bookingId.isEmpty) {
      throw Exception("Booking id is required.");
    }
    await _bookingRepository.rateBooking(
      bookingId: bookingId,
      rating: rating,
    );
  }
}
