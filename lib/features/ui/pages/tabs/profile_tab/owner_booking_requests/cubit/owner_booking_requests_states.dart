import 'package:sokon/core/model/booking.dart';

abstract class OwnerBookingRequestsStates {}

class OwnerBookingRequestsInitial extends OwnerBookingRequestsStates {}

class OwnerBookingRequestsLoading extends OwnerBookingRequestsStates {}

class OwnerBookingRequestsSuccess extends OwnerBookingRequestsStates {
  final List<Booking> bookings;
  OwnerBookingRequestsSuccess(this.bookings);
}

class OwnerBookingRequestsError extends OwnerBookingRequestsStates {
  final String message;
  OwnerBookingRequestsError(this.message);
}
