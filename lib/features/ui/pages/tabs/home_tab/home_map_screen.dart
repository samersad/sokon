import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/core/utils/app_styles.dart';

class HomeMapArguments {
  const HomeMapArguments({
    required this.apartments,
    required this.userLocation,
    required this.userPhotoUrl,
  });

  final List<ApartmentResponse> apartments;
  final LatLng? userLocation;
  final String? userPhotoUrl;
}

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key, required this.arguments});

  final HomeMapArguments arguments;

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  GoogleMapController? _controller;
  Set<Marker> _markers = const {};
  bool _isLoadingMarkers = true;

  List<ApartmentResponse> get _apartmentsWithLocation {
    return widget.arguments.apartments
        .where((apartment) => apartment.lat != null && apartment.lng != null)
        .toList();
  }

  LatLng get _initialLocation {
    final userLocation = widget.arguments.userLocation;
    if (userLocation != null) return userLocation;
    if (_apartmentsWithLocation.isNotEmpty) {
      final apartment = _apartmentsWithLocation.first;
      return LatLng(apartment.lat!, apartment.lng!);
    }
    return _defaultLocation;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _buildMarkers() async {
    final markers = <Marker>{};
    final userLocation = widget.arguments.userLocation;

    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: userLocation,
          anchor: const Offset(0.5, 0.5),
          icon: await _buildCircleImageMarker(
            imageUrl: widget.arguments.userPhotoUrl,
            fallbackAsset: AppAssets.profileImage,
            borderColor: AppColors.whiteBlue,
            size: 118,
          ),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );
    }

    for (final apartment in _apartmentsWithLocation) {
      final imageUrl = apartment.images?.isNotEmpty == true
          ? apartment.images!.first
          : null;
      markers.add(
        Marker(
          markerId: MarkerId("apartment_${apartment.id ?? markers.length}"),
          position: LatLng(apartment.lat!, apartment.lng!),
          anchor: const Offset(0.5, 1),
          icon: await _buildApartmentImageMarker(
            imageUrl: imageUrl,
            fallbackAsset: AppAssets.image,
          ),
          infoWindow: InfoWindow(
            title: apartment.name ?? "Apartment",
            snippet: apartment.displayLocationLabel,
          ),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.apartmentDetailsRoute,arguments: apartment);
          },
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _markers = markers;
      _isLoadingMarkers = false;
    });
    await _fitMapToMarkers();
  }

  Future<void> _fitMapToMarkers() async {
    final controller = _controller;
    if (controller == null || _markers.isEmpty) return;

    if (_markers.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _markers.first.position, zoom: 15),
        ),
      );
      return;
    }

    final bounds = _boundsFor(_markers.map((marker) => marker.position));
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  LatLngBounds _boundsFor(Iterable<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<Uint8List> _loadImageBytes(String? imageUrl, String fallbackAsset) async {
    try {
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        final data = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
        return data.buffer.asUint8List();
      }
    } catch (_) {
      // Fall back to a bundled asset if a remote image cannot be loaded.
    }

    final data = await rootBundle.load(fallbackAsset);
    return data.buffer.asUint8List();
  }

  Future<BitmapDescriptor> _buildCircleImageMarker({
    required String? imageUrl,
    required String fallbackAsset,
    required Color borderColor,
    required int size,
  }) async {
    final imageBytes = await _loadImageBytes(imageUrl, fallbackAsset);
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: size,
      targetHeight: size,
    );
    final frame = await codec.getNextFrame();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final markerSize = size.toDouble();
    final center = Offset(markerSize / 2, markerSize / 2);
    final imageRadius = markerSize / 2 - 8;

    canvas.drawCircle(center, markerSize / 2, Paint()..color = borderColor);
    canvas.drawCircle(center, imageRadius, Paint()..color = AppColors.whiteColor);
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: imageRadius - 3)),
    );
    canvas.drawImageRect(
      frame.image,
      Rect.fromLTWH(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
      Rect.fromCircle(center: center, radius: imageRadius - 3),
      Paint(),
    );
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _buildApartmentImageMarker({
    required String? imageUrl,
    required String fallbackAsset,
  }) async {
    const markerWidth = 108;
    const markerHeight = 128;
    final imageBytes = await _loadImageBytes(imageUrl, fallbackAsset);
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: markerWidth,
      targetHeight: markerWidth,
    );
    final frame = await codec.getNextFrame();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final cardRect = RRect.fromLTRBR(
      4,
      4,
      markerWidth - 4,
      markerWidth - 4,
      const Radius.circular(24),
    );
    final pointer = Path()
      ..moveTo(markerWidth / 2 - 14, markerWidth - 10)
      ..lineTo(markerWidth / 2, markerHeight - 4)
      ..lineTo(markerWidth / 2 + 14, markerWidth - 10)
      ..close();

    canvas.drawShadow(pointer, AppColors.blackColor, 4, true);
    canvas.drawPath(pointer, Paint()..color = AppColors.whiteColor);
    canvas.drawRRect(cardRect, Paint()..color = AppColors.whiteColor);
    canvas.save();
    canvas.clipRRect(
      RRect.fromLTRBR(10, 10, markerWidth - 10, markerWidth - 10, const Radius.circular(20)),
    );
    canvas.drawImageRect(
      frame.image,
      Rect.fromLTWH(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
      Rect.fromLTWH(10, 10, markerWidth - 20, markerWidth - 20),
      Paint(),
    );
    canvas.restore();
    canvas.drawRRect(
      cardRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppColors.whiteColor,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(markerWidth, markerHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) async {
              _controller = controller;
              await _fitMapToMarkers();
            },
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Material(
                      color: theme.cardColor,
                      shape: const CircleBorder(),
                      elevation: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 48.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackColor.withOpacity(0.14),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Apartments on Map",
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoadingMarkers)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 20.h,
            child: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.apartment_rounded, color: theme.primaryColor),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "${_apartmentsWithLocation.length} apartments with map locations",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: _fitMapToMarkers,
                      child: const Text("Fit"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
