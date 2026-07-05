import 'package:flutter/material.dart';

enum BookingStatus { initial, loading, success, error }

class BookingStates {
  final DateTimeRange? selectedDate;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final int peopleCount;
  final bool showDateError;
  final BookingStatus status;
  final String? errorMessage;
  final bool requiresPhoneVerification;

  const BookingStates({
    this.selectedDate,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.peopleCount = 1,
    this.showDateError = false,
    this.status = BookingStatus.initial,
    this.errorMessage,
    this.requiresPhoneVerification = false,
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
    int? peopleCount,
    bool? showDateError,
    BookingStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? requiresPhoneVerification,
  }) {
    return BookingStates(
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      cardNumber: clearCardNumber ? null : (cardNumber ?? this.cardNumber),
      cardHolder: clearCardHolder ? null : (cardHolder ?? this.cardHolder),
      expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
      peopleCount: peopleCount ?? this.peopleCount,
      showDateError: showDateError ?? this.showDateError,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      requiresPhoneVerification:
          requiresPhoneVerification ?? this.requiresPhoneVerification,
    );
  }
}
