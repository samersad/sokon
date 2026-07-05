import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/location_states.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isResolvingAddress = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final locationViewModel = context.read<LocationViewModel>();
    _selectedLocation = locationViewModel.apartmentLocation;
    _selectedAddress = locationViewModel.apartmentAddress;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationViewModel>().getCurrentLocation();
    });
  }

  Future<void> _handleMapTap(LatLng latLng) async {
    final locationViewModel = context.read<LocationViewModel>();
    setState(() {
      _selectedLocation = latLng;
      _isResolvingAddress = true;
    });

    final address = await locationViewModel.getAddressFromLatLng(latLng);
    if (!mounted) return;

    setState(() {
      _selectedAddress = address;
      _isResolvingAddress = false;
    });
  }

  Future<void> _confirmSelection() async {
    final selectedLocation = _selectedLocation;
    if (selectedLocation == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await context.read<LocationViewModel>().changeApartmentLocation(
      selectedLocation,
      resolvedAddress: _selectedAddress,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationViewModel = context.read<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickApartmentLocation),
        centerTitle: true,
      ),
      body: BlocBuilder<LocationViewModel, LocationState>(
        builder: (context, state) {
          LatLng initialTarget;
          if (_selectedLocation != null) {
            initialTarget = _selectedLocation!;
          } else if (locationViewModel.apartmentLocation != null) {
            initialTarget = locationViewModel.apartmentLocation!;
          } else if (locationViewModel.userLocation != null) {
            initialTarget = locationViewModel.userLocation!;
          } else {
            initialTarget = const LatLng(27.185472212549193, 31.18254273654902);
          }

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 170.h),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 15,
                  ),
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId("Selected Location"),
                            position: _selectedLocation!,
                          ),
                        }
                      : {},
                  onTap: _handleMapTap,
                ),
              ),
              Positioned(
                right: 16.w,
                left: 16.w,
                bottom: 16.h,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42.w,
                              height: 42.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.place_rounded,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select location",
                                    style: AppStyles.bold16PrimaryColor,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10n.tapMapToPlaceMarker,
                                    style: AppStyles.regular12gray,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColors.offWhiteColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: _isResolvingAddress
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        l10n.loadingSelectedAddress,
                                        style: AppStyles.regular12gray,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _selectedAddress?.trim().isNotEmpty == true
                                      ? _selectedAddress!
                                      : l10n.noLocationSelected,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.regular14black,
                                ),
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedLocation == null || _isSubmitting
                                ? null
                                : _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              disabledBackgroundColor:
                                  AppColors.primaryColor.withOpacity(0.35),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    l10n.confirmLocation,
                                    style: AppStyles.semiBold14White,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
