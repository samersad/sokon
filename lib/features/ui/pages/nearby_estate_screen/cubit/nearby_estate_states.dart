import '../../../../../core/model/apartment.dart';

abstract class NearbyEstateStates {}

class NearbyEstateInitial extends NearbyEstateStates {}

class NearbyEstateLoading extends NearbyEstateStates {}

class NearbyEstateSuccess extends NearbyEstateStates {
  final List<Apartment> apartments;
  NearbyEstateSuccess(this.apartments);
}

class NearbyEstateError extends NearbyEstateStates {
  final String message;
  NearbyEstateError(this.message);
}
