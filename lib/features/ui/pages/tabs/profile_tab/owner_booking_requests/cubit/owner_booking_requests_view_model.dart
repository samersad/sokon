import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../../supabase_utils.dart';
import 'owner_booking_requests_states.dart';

@injectable
class OwnerBookingRequestsViewModel extends Cubit<OwnerBookingRequestsStates> {
  OwnerBookingRequestsViewModel() : super(OwnerBookingRequestsInitial());

  StreamSubscription? _bookingsSubscription;

  Future<void> getOwnerBookings(String ownerId) async {
    emit(OwnerBookingRequestsLoading());
    await _bookingsSubscription?.cancel();
    try {
      _bookingsSubscription = SupabaseUtils.getOwnerBookingsStream(ownerId)
          .listen(
        (bookings) {
          emit(OwnerBookingRequestsSuccess(bookings));
        },
        onError: (error) {
          emit(OwnerBookingRequestsError(error.toString()));
        },
      );
    } catch (e) {
      emit(OwnerBookingRequestsError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _bookingsSubscription?.cancel();
    return super.close();
  }
}
