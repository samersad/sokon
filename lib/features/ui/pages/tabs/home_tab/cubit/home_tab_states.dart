import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/model/apartment.dart';

abstract class HomeTabStates {}

class HomeTabInitial extends HomeTabStates {}

class HomeTabLoading extends HomeTabStates {}

class HomeTabError extends HomeTabStates {
  final String message;
  HomeTabError(this.message);
}

class HomeTabUserLocationLoaded extends HomeTabStates {
  final LatLng? userLocation;

  HomeTabUserLocationLoaded({
    this.userLocation,
  });
}
class HomeTabUserAddressLoaded extends HomeTabStates {

  final String? address;

  HomeTabUserAddressLoaded({

    this.address,
  });
}
class HomeTabNearbyEstateLoaded extends HomeTabStates {
  final List<Apartment> allApartments;

  HomeTabNearbyEstateLoaded({
    required this.allApartments,
  });
}
class HomeTabFeaturedEstateLoaded extends HomeTabStates {
  final List<Apartment> allApartments;

  HomeTabFeaturedEstateLoaded({
    required this.allApartments,
  });
}
