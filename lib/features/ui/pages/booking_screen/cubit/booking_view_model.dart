import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/model/booking.dart';
import '../../../../../data/repository/booking/repository/booking_repository.dart';
import 'booking_states.dart';

@injectable
class BookingViewModel extends Cubit<BookingStates> {
  final UserViewModel userViewModel;
  final BookingRepository bookingRepository;

  BookingViewModel(this.userViewModel, this.bookingRepository)
      : super(BookingInitial());

  DateTimeRange? selectedDate;
  String? cardNumber;
  String? cardHolder;
  String? expiryDate;

  void selectDateRange(DateTimeRange? picked) {
    selectedDate = picked;
    emit(BookingDateSelected(selectedDate));
  }

  void updateCardData(Map<String, dynamic> data) {
    cardNumber = data["cardNumber"];
    cardHolder = data["cardHolder"];
    expiryDate = data["expiryDate"];
    emit(BookingCardUpdated(
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      expiryDate: expiryDate,
    ));
  }

  String getFormattedDate() {
    if (selectedDate == null) return "Select Date";
    final format = DateFormat('dd MMM');
    return "${format.format(selectedDate!.start)} - ${format.format(selectedDate!.end)}";
  }

  Future<void> confirmBooking(Apartment apartment) async {
    if (selectedDate == null) {
      emit(BookingError("Please select a date range"));
      return;
    }

    if (userViewModel.user == null) {
      emit(BookingError("Please login to book"));
      return;
    }

    emit(BookingLoading());

    Booking booking = Booking(
      apartmentId: apartment.id,
      apartmentName: apartment.name,
      apartmentAddress: apartment.address,
      apartmentImage: (apartment.images != null && apartment.images!.isNotEmpty)
          ? apartment.images![0]
          : null,
      clientId: userViewModel.user!.id,
      clientName: userViewModel.user!.name,
      ownerId: apartment.ownerId,
      ownerName: apartment.ownerName,
      startDate: selectedDate!.start,
      endDate: selectedDate!.end,
      totalPrice: apartment.price,
      status: 'pending',
    );

    try {
      await bookingRepository.addBooking(booking);
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
