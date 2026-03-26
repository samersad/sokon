import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationState {}
class LocationInitial extends LocationState {}
class LocationLoading extends LocationState {}
class LocationUpdated extends LocationState {
  final LatLng? userLocation;
  final String? userAddress;
  final LatLng? apartmentLocation;
  final String? apartmentAddress;

  LocationUpdated({
    this.userLocation,
    this.userAddress,
    this.apartmentLocation,
    this.apartmentAddress,
  });
}