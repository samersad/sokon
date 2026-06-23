import 'package:sokon/core/model/BookingResponse.dart';

abstract class MyBookingsStates {}

class MyBookingsInitial extends MyBookingsStates {}

class MyBookingsLoading extends MyBookingsStates {}

class MyBookingsSuccess extends MyBookingsStates {
  final List<BookingResponse> bookings;
  MyBookingsSuccess(this.bookings);
}

class MyBookingsError extends MyBookingsStates {
  final String message;
  MyBookingsError(this.message);
}
