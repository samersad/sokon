import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import 'location_states.dart';


@lazySingleton
class LocationViewModel extends Cubit<LocationState> {
  LocationViewModel() : super(LocationInitial());

  LatLng? userLocation;
  String? userAddress;
  LatLng? apartmentLocation;
  String? apartmentAddress;

  Future<void> getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      emit(LocationLoading());
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(position.latitude, position.longitude);
      userAddress = await getAddressFromLatLng(userLocation!);
      emit(LocationUpdated(
        userLocation: userLocation,
        userAddress: userAddress,
        apartmentLocation: apartmentLocation,
        apartmentAddress: apartmentAddress,
      ));
    } else if (permission.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> changeApartmentLocation(
    LatLng latLng, {
    String? resolvedAddress,
  }) async {
    emit(LocationLoading());
    apartmentLocation = latLng;
    apartmentAddress =
        resolvedAddress ?? await getAddressFromLatLng(apartmentLocation!);
    emit(LocationUpdated(
      userLocation: userLocation,
      userAddress: userAddress,
      apartmentLocation: apartmentLocation,
      apartmentAddress: apartmentAddress,
    ));
  }

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name},${place.street} ,${place.subLocality}, ${place.locality}, ${place.locality}";
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }
    return "Unknown Address";
  }

  Future<void> changeUserLocation(
    LatLng latLng, {
    String? resolvedAddress,
  }) async {
    emit(LocationLoading());
    userLocation = latLng;
    userAddress = resolvedAddress ?? await getAddressFromLatLng(latLng);
    emit(LocationUpdated(
      userLocation: userLocation,
      userAddress: userAddress,
      apartmentLocation: apartmentLocation,
      apartmentAddress: apartmentAddress,
    ));
  }

  void clearApartmentLocation() {
    apartmentLocation = null;
    apartmentAddress = null;
    emit(LocationUpdated(
      userLocation: userLocation,
      userAddress: userAddress,
      apartmentLocation: apartmentLocation,
      apartmentAddress: apartmentAddress,
    ));
  }
}
