import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/cache/provider/location_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context,listen: false).getCurrentLocation();

    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:  Stack(
        children: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {

              LatLng initialTarget;
              if (locationProvider.apartmentLocation != null) {
                initialTarget = locationProvider.apartmentLocation!;
              } else if (locationProvider.userLocation != null) {
                initialTarget = locationProvider.userLocation!;
              } else {
                initialTarget = const LatLng( 27.185472212549193, 31.18254273654902);
              }
              return
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: locationProvider.apartmentLocation != null
                      ? {
                    Marker(
                      markerId: const MarkerId("Selected Location"),
                      position: locationProvider.apartmentLocation!,
                    ),
                  }
                      : {},
                  onTap: (LatLng latLng) {
                    locationProvider.changeApartmentLocation(latLng);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.pop(context);
                    });
                  },
                );
            },
          ),
          Positioned(
            right: 0,
            left: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Center(child: Text("Tap On Location To Select ",style: AppStyles.bold20blackIner,)),
          )),

    ],
      ),
    );
  }
}