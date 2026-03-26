import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/model/apartment.dart';
import 'apartment_details_states.dart';

@injectable
class ApartmentDetailsViewModel extends Cubit<ApartmentDetailsStates> {
  ApartmentDetailsViewModel() : super(ApartmentDetailsInitial());

  Apartment? apartment;

  void initApartment(Apartment apartment) {
    this.apartment = apartment;
    emit(ApartmentDetailsLoading());
    try {
      emit(ApartmentDetailsSuccess(apartment));
    } catch (e) {
      emit(ApartmentDetailsError(e.toString()));
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  bool canUserRent(String? userId, String? userRole) {
    if (userRole != 'client') return false;
    if (userId == apartment?.ownerId) return false;
    return true;
  }
}
