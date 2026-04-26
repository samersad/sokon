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
      : super(const BookingStates());

  void selectDateRange(DateTimeRange? picked) {
    emit(
      state.copyWith(
        selectedDate: picked,
        showDateError: false,
        status: BookingStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  void updateCardData(Map<String, dynamic> data) {
    emit(
      state.copyWith(
        cardNumber: data["cardNumber"],
        cardHolder: data["cardHolder"],
        expiryDate: data["expiryDate"],
        status: BookingStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  String getFormattedDate() {
    if (state.selectedDate == null) return "Select Date";
    final format = DateFormat('dd MMM');
    return "${format.format(state.selectedDate!.start)} - ${format.format(state.selectedDate!.end)}";
  }

  Future<void> confirmBooking(Apartment apartment) async {
    if (state.selectedDate == null) {
      emit(
        state.copyWith(
          showDateError: true,
          status: BookingStatus.error,
          errorMessage: "Please select a date range",
        ),
      );
      return;
    }

    if (userViewModel.user == null) {
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: "Please login to book",
        ),
      );
      return;
    }

    final hasActiveBooking = await bookingRepository.hasActiveBookingForApartment(
      userId: userViewModel.user!.id!,
      apartmentId: apartment.id!,
    );
    if (hasActiveBooking) {
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: "You already rented this apartment. You can book it again after your current period ends.",
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        showDateError: false,
        status: BookingStatus.loading,
        clearErrorMessage: true,
      ),
    );

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
      startDate: state.selectedDate!.start,
      endDate: state.selectedDate!.end,
      totalPrice: apartment.price,
      status: 'pending',
    );

    try {
      await bookingRepository.addBooking(booking);
      emit(
        state.copyWith(
          status: BookingStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BookingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
