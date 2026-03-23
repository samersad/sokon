import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/location_states.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';

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
    // Get the global location if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationViewModel>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationViewModel = context.read<LocationViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<LocationViewModel, LocationState>(
            builder: (context, state) {
              LatLng initialTarget;
              if (locationViewModel.apartmentLocation != null) {
                initialTarget = locationViewModel.apartmentLocation!;
              } else if (locationViewModel.userLocation != null) {
                initialTarget = locationViewModel.userLocation!;
              } else {
                initialTarget = const LatLng(27.185472212549193, 31.18254273654902);
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 15,
                ),
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: locationViewModel.apartmentLocation != null
                    ? {
                  Marker(
                    markerId: const MarkerId("Selected Location"),
                    position: locationViewModel.apartmentLocation!,
                  ),
                }
                    : {},
                onTap: (LatLng latLng) {
                  // 3. This now updates the global state that AddApartment is watching
                  locationViewModel.changeApartmentLocation(latLng);
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
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Center(
                child: Text(
                  "Tap On Location To Select ",
                  style: AppStyles.bold20blackIner,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}