import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? userLocation;
  LatLng? apartmentLocation;
  String? apartmentAddress;

  Future<void> getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(position.latitude, position.longitude);
      print(userLocation);

      notifyListeners();
    } else if (permission.isPermanentlyDenied) {
      openAppSettings();
    } else {}
  }

  Future<void> changeEventLocation(LatLng latLng) async {
    apartmentLocation = latLng;
    apartmentAddress = await getLocationFromAddress();

    notifyListeners();
  }

  Future<String> getLocationFromAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      apartmentLocation!.latitude,
      apartmentLocation!.longitude,
    );
    print("eventAddress");

    print("${placemarks[0]}");
    print(apartmentAddress);

    return "${placemarks[0].name}, "
        "${placemarks[0].street},"
        "${placemarks[0].thoroughfare},"
        " ${placemarks[0].subLocality}, "
        "${placemarks[0].locality},"
        " ${placemarks[0].postalCode},";
  }

  void clearEventLocation() {
    apartmentLocation = null;
    apartmentAddress = null;
    notifyListeners();
  }
}
