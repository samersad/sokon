import 'package:flutter/material.dart';

enum BookingStatus { initial, loading, success, error }

class BookingStates {
  final DateTimeRange? selectedDate;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final bool showDateError;
  final BookingStatus status;
  final String? errorMessage;

  const BookingStates({
    this.selectedDate,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.showDateError = false,
    this.status = BookingStatus.initial,
    this.errorMessage,
  });

  BookingStates copyWith({
    DateTimeRange? selectedDate,
    bool clearSelectedDate = false,
    String? cardNumber,
    bool clearCardNumber = false,
    String? cardHolder,
    bool clearCardHolder = false,
    String? expiryDate,
    bool clearExpiryDate = false,
    bool? showDateError,
    BookingStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingStates(
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      cardNumber: clearCardNumber ? null : (cardNumber ?? this.cardNumber),
      cardHolder: clearCardHolder ? null : (cardHolder ?? this.cardHolder),
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      showDateError: showDateError ?? this.showDateError,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
