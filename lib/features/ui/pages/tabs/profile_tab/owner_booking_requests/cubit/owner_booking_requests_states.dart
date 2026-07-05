import 'package:sokon/core/model/BookingResponse.dart';

abstract class OwnerBookingRequestsStates {}

class OwnerBookingRequestsInitial extends OwnerBookingRequestsStates {}

class OwnerBookingRequestsLoading extends OwnerBookingRequestsStates {}

class OwnerBookingRequestsSuccess extends OwnerBookingRequestsStates {
  final List<BookingResponse> bookings;
  OwnerBookingRequestsSuccess(this.bookings);
}

class OwnerBookingRequestsError extends OwnerBookingRequestsStates {
  final String message;
  OwnerBookingRequestsError(this.message);
}
