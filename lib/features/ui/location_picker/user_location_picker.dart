import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/location_states.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';

class UserLocationPicker extends StatefulWidget {
  const UserLocationPicker({super.key});

  @override
  State<UserLocationPicker> createState() => _UserLocationPickerState();
}

class _UserLocationPickerState extends State<UserLocationPicker> {
  @override
  Widget build(BuildContext context) {
    final locationViewModel = context.read<LocationViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<LocationViewModel, LocationState>(
            builder: (context, state) {
              LatLng initialTarget;
              if (locationViewModel.userLocation != null) {
                initialTarget = locationViewModel.userLocation!;
              } else {
                initialTarget = const LatLng(30.0444, 31.2357);
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
                markers: locationViewModel.userLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId("User Location"),
                          position: locationViewModel.userLocation!,
                        ),
                      }
                    : {},
                onTap: (LatLng latLng) {
                  locationViewModel.changeUserLocation(latLng);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) Navigator.pop(context);
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
                  "Tap On Location To Select",
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
