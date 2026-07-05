import '../../model/booking.dart';

abstract class MyBookingState {}

class MyBookingInitial extends MyBookingState {}

class MyBookingLoading extends MyBookingState {}

class MyBookingLoaded extends MyBookingState {
  final List<Booking> bookings;
  MyBookingLoaded(this.bookings);
}

class MyBookingError extends MyBookingState {
  final String message;
  MyBookingError(this.message);
}
