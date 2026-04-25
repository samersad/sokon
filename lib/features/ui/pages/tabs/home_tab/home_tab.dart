import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_states.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_view_model.dart';

import '../../../../../core/utils/app_styles.dart';
import '../../../widgets/featured_estates_card.dart';
import '../../../widgets/nearby_estate_card.dart';
import '../../../widgets/search_widget.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final HomeTabViewModel viewModel = getIt<HomeTabViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.getUserLocationData();
    viewModel.getFeaturedEstateData();
    viewModel.getNearbyEstateData();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final user = userViewModel.user;

    return BlocBuilder<HomeTabViewModel, HomeTabStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.my_location),
                                      title: const Text("Use Current Location"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        viewModel.getUserLocationData();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.map),
                                      title: const Text("Pick on Map"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.userLocationPickerRoute,
                                        ).then((_) => viewModel.refreshUserLocation());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 50.h,
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
                                  child: Builder(
                                    builder: (context) {
                                      String address = viewModel.locationViewModel.userAddress ?? "Select Location";
                                      return Text(
                                        address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.medium10blueDarkColor,
                                      );
                                    }
                                  ),
                                ),
                                Image.asset(AppAssets.downIcon, width: 14.w),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {},
                        child: Image.asset(AppAssets.chatBot, width: 24.w),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.notificationRoute);
                        },
                        child: Image.asset(AppAssets.notification, width: 24.w),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                              ? NetworkImage(user.photoUrl!)
                              : AssetImage(AppAssets.profileImage) as ImageProvider,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  const SearchWidget(
                    hintText: "Search House, Apartment, etc",
                  ),

                  SizedBox(height: 20.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 170.h,
                      child: Builder(
                        builder: (context) {
                          LatLng? location = viewModel.locationViewModel.userLocation;
                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: location ?? const LatLng(30.0444, 31.2357),
                                zoom: 15),
                            zoomControlsEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            scrollGesturesEnabled: true,
                            markers: location != null
                                ? {
                                    Marker(
                                      markerId: const MarkerId("Current Location"),
                                      position: location,
                                    )
                                  }
                                : {},
                          );
                        }
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text("Featured Estates", style: AppStyles.bold18PrimaryColor),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.featuredEstateRoute);
                        },
                        child: Text("View all", style: AppStyles.semiBold10PrimaryColor),
                      )
                    ],
                  ),

                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 185.h,
                    child: Builder(
                      builder: (context) {
                        final apartments = viewModel.apartmentViewModel.apartmentList;
                        if (state is HomeTabLoading && apartments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (apartments.isNotEmpty) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: apartments.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (_, index) {
                              return FeaturedEstatesCard(apartment: apartments[index]);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text("Top Location", style: AppStyles.bold18PrimaryColor),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.topLocationRoute);
                        },
                        child: Text("View all", style: AppStyles.semiBold10PrimaryColor),
                      )
                    ],
                  ),

                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 60.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (_, __) {
                        return Container(
                          width: 130.w,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: AppColors.offWhiteColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            children: [
                              Image.asset(AppAssets.imageS, width: 28.w),
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
                      Text("Nearby Estate", style: AppStyles.bold18PrimaryColor),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.nearbyEstateRoute);
                        },
                        child: Text("View all", style: AppStyles.semiBold10PrimaryColor),
                      )
                    ],
                  ),

                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 285.h,
                    child: Builder(
                      builder: (context) {
                        final apartments = viewModel.apartmentViewModel.apartmentList;
                         if (state is HomeTabLoading && apartments.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (apartments.isNotEmpty) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: apartments.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (_, index) {
                              return NearbyEstateCard(apartment: apartments[index]);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    ),
                  ),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
