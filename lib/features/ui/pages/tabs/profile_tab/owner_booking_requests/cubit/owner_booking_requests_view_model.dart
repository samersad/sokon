import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sokon/data/repository/booking/data_sources/remote/impl/booking_remote_data_impl.dart';
import 'package:sokon/data/repository/booking/repository/booking_repository.dart';
import 'package:sokon/data/repository/booking/repository/impl/booking_repository_impl.dart';

import 'owner_booking_requests_states.dart';

@injectable
class OwnerBookingRequestsViewModel extends Cubit<OwnerBookingRequestsStates> {
  OwnerBookingRequestsViewModel() : super(OwnerBookingRequestsInitial());

  final BookingRepository _bookingRepository =
      BookingRepositoryImpl(BookingRemoteDataImpl());

  Future<void> getOwnerBookings(String ownerId) async {
    emit(OwnerBookingRequestsLoading());
    try {
      final bookings = await _bookingRepository.getOwnerBookings(ownerId);
      emit(OwnerBookingRequestsSuccess(bookings));
    } catch (e) {
      emit(OwnerBookingRequestsError(e.toString()));
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
}
