import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/firebase_utils.dart';
import 'my_bookings_states.dart';

class MyBookingsViewModel extends Cubit<MyBookingsStates> {
  MyBookingsViewModel() : super(MyBookingsInitial());

  List<Booking> bookingsList = [];
  StreamSubscription? _subscription;

  void getMyBookings(String userId) {
    emit(MyBookingsLoading());
    _subscription?.cancel();
    try {
      _subscription = FireBaseUtils.getBookingsStream(userId).listen((event) {
        bookingsList = event.docs.map((e) => e.data()).toList();
        emit(MyBookingsSuccess(bookingsList));
      }, onError: (error) {
        emit(MyBookingsError(error.toString()));
      });
    } catch (e) {
      emit(MyBookingsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
