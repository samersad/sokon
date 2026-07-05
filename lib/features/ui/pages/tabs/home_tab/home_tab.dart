import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/features/ui/widgets/custom_text_form_field.dart';

import '../../../../../core/cache/provider/location_provider.dart';
import '../../../../../core/utils/app_styles.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    final LatLng initialTarget =
        locationProvider.eventLocation ??
            locationProvider.userLocation ??
            const LatLng(30.0444, 31.2357);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  Top Bar
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 50.h,
                      width: 160.w, //
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppColors.grayColor),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppAssets.locationIcon, width: 16.w),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              "Jakarta, Indonesia",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.medium10blueDarkColor,
                            ),
                          ),
                          Image.asset(AppAssets.downIcon, width: 14.w),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Image.asset(AppAssets.chatBot, width: 24.w),
                  SizedBox(width: 10.w),
                  Image.asset(AppAssets.notification, width: 24.w),
                ],
              ),

              SizedBox(height: 20.h),

              ///  Search
              CustomTextFormField(
                borderRadius: 14,
                fillColor: AppColors.whiteColor,
                borderSideColor: AppColors.grayColor,
                hintText: "Search House, Apartment, etc",
                hintStyle: AppStyles.medium12gray,
                prefixIconName: Image.asset(AppAssets.searchIcon),
                suffixIconName: InkWell(
                  onTap: () {},
                  child: Image.asset(AppAssets.filterIcon),
                ),
              ),

              SizedBox(height: 20.h),

              /// Map
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 170.h,
                  child: GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: initialTarget, zoom: 15),
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: locationProvider.eventLocation != null
                        ? {
                      Marker(
                        markerId:
                        const MarkerId("Selected Location"),
                        position:
                        locationProvider.eventLocation!,
                      )
                    }
                        : {},
                    onTap: locationProvider.changeEventLocation,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              ///  Featured title
              Row(
                children: [
                  Text("Featured Estates",
                      style: AppStyles.bold18PrimaryColor),
                  const Spacer(),
                  Text("View all",
                      style: AppStyles.semiBold10PrimaryColor),
                ],
              ),

              SizedBox(height: 10.h),

              ///  Featured list
              SizedBox(
                height: 170.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, __) {
                    return Container(
                      width: 270.w,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.offWhiteColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppAssets.image,
                              width: 120.w, fit: BoxFit.fill),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                AutoSizeText(
                                  "Sky Dandelions Apartment",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.bold12Primary,
                                ),
                                Row(
                                  children: [
                                    Image.asset(AppAssets.star,
                                        width: 14.w),
                                    SizedBox(width: 4.w),
                                    Text("4.9",
                                        style:
                                        AppStyles.bold12Primary),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                        AppAssets.locationIcon,
                                        width: 14.w),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        "Jakarta, Indonesia",
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: AppStyles
                                            .medium10blueDarkColor,
                                      ),
                                    ),
                                  ],
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "EG 290/",
                                        style: AppStyles
                                            .bold18PrimaryColor,
                                      ),
                                      TextSpan(
                                        text: "month",
                                        style:
                                        AppStyles.bold8Primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),

              ///  Top location
              Row(
                children: [
                  Text("Top Location",
                      style: AppStyles.bold18PrimaryColor),
                  const Spacer(),
                  Text("View all",
                      style: AppStyles.semiBold10PrimaryColor),
                ],
              ),

              SizedBox(height: 10.h),

              SizedBox(
                height: 52.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, __) {
                    return Container(
                      width: 123.w,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.offWhiteColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppAssets.imageS,
                              width: 28.w),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              "Malang",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.bold12Primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),

              Row(
                children: [
                  Text("Nearby Estate",
                      style: AppStyles.bold18PrimaryColor),
                  const Spacer(),
                  Text("View all",
                      style: AppStyles.semiBold10PrimaryColor),
                ],
              ),

              SizedBox(height: 10.h),

              SizedBox(
                height: 250.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (_, __) {
                    return Container(
                      width: 168.w,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.offWhiteColor,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                AppAssets.imageC,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            "Bungalow House",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bold12Primary,
                          ),

                          SizedBox(height: 6.h),

                          Row(
                            children: [
                              Image.asset(AppAssets.locationOrange, width: 14.w),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "Jakarta, Indonesia",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.medium10blueDarkColor,
                                ),
                              ),
                              Image.asset(AppAssets.downIcon, width: 12.w),
                            ],
                          ),

                          SizedBox(height: 10.h), // 👈 بدل Spacer

                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "EG 290/",
                                      style: AppStyles.bold18PrimaryColor,
                                    ),
                                    TextSpan(
                                      text: "month",
                                      style: AppStyles.bold8Primary,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Image.asset(AppAssets.star, width: 14.w),
                              SizedBox(width: 4.w),
                              Text("4.7", style: AppStyles.bold12Primary),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 60.h),

            ],
          ),
        ),
      ),
    );
  }
}


