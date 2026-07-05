import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/utils/app_routes.dart';

import '../../../core/utils/app_assets.dart';

class NearbyEstateCard extends StatelessWidget {
  final ApartmentResponse apartment;
  final LatLng? referenceLocation;
  const NearbyEstateCard({super.key, required this.apartment, this.referenceLocation});

  String _calculateDistance() {
    if (referenceLocation == null || apartment.lat == null || apartment.lng == null) {
      return "";
    }
    final distanceInMeters = Geolocator.distanceBetween(
      referenceLocation!.latitude,
      referenceLocation!.longitude,
      apartment.lat!,
      apartment.lng!,
    );
    final distanceInKm = distanceInMeters / 1000;
    return "${distanceInKm.toStringAsFixed(1)} km";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.apartmentDetailsRoute, arguments: apartment),
      child: Container(
        width: 190.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: theme.disabledColor,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: apartment.images != null && apartment.images!.isNotEmpty
                    ? Image.network(
                        apartment.images![0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(AppAssets.imageC, fit: BoxFit.cover),
                      )
                    : Image.asset(AppAssets.imageC, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              apartment.name ?? l10n.noName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.displaySmall,
            ),

            SizedBox(height: 6.h),

            Row(
              children: [
                Image.asset(AppAssets.locationOrange, width: 14.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    apartment.displayLocationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                if (_calculateDistance().isNotEmpty)
                  Text(
                    _calculateDistance(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10.h),

            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "EG ${apartment.price ?? 0}/",
                          style: theme.textTheme.displaySmall,
                          // color: theme.highlightColor
                        ),
                        TextSpan(
                          text: "month",
                          style: theme.textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(AppAssets.star, width: 14.w),
                SizedBox(width: 4.w),
                Text(
                  apartment.ratingLabel,
                  style: theme.textTheme.displaySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
