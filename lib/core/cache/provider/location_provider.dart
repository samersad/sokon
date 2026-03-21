import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? userLocation;
  String? userAddress;
  LatLng? apartmentLocation;
  String? apartmentAddress;

  Future<void> getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(position.latitude, position.longitude);
      userAddress = await getAddressFromLatLng(userLocation!);
      notifyListeners();
    } else if (permission.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> changeApartmentLocation(LatLng latLng) async {
    apartmentLocation = latLng;
    apartmentAddress = await getAddressFromLatLng(apartmentLocation!);
    notifyListeners();
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

  // Keeping the old method name for compatibility if used elsewhere, 
  // but redirecting to the new generic one.
  void clearApartmentLocation() {
    apartmentLocation = null;
    apartmentAddress = null;
    notifyListeners();
  }
}
