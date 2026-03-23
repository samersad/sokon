import '../../../../../core/model/apartment.dart';

abstract class ApartmentDetailsStates {}

class ApartmentDetailsInitial extends ApartmentDetailsStates {}

class ApartmentDetailsLoading extends ApartmentDetailsStates {}

class ApartmentDetailsSuccess extends ApartmentDetailsStates {
  final Apartment apartment;
  ApartmentDetailsSuccess(this.apartment);
}

class ApartmentDetailsError extends ApartmentDetailsStates {
  final String message;
  ApartmentDetailsError(this.message);
}
