import 'package:sokon/core/model/booking.dart';

abstract class MyBookingsStates {}

class MyBookingsInitial extends MyBookingsStates {}

class MyBookingsLoading extends MyBookingsStates {}

class MyBookingsSuccess extends MyBookingsStates {
  final List<Booking> bookings;
  MyBookingsSuccess(this.bookings);
}

class MyBookingsError extends MyBookingsStates {
  final String message;
  MyBookingsError(this.message);
}
