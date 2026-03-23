import 'package:flutter/material.dart';

abstract class BookingStates {}

class BookingInitial extends BookingStates {}

class BookingLoading extends BookingStates {}

class BookingSuccess extends BookingStates {}

class BookingError extends BookingStates {
  final String message;
  BookingError(this.message);
}

class BookingDateSelected extends BookingStates {
  final DateTimeRange? selectedDate;
  BookingDateSelected(this.selectedDate);
}

class BookingCardUpdated extends BookingStates {
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  BookingCardUpdated({this.cardNumber, this.cardHolder, this.expiryDate});
}
