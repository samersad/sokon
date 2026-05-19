import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/notifaction_screen/cubit/notification_states.dart';
import 'package:sokon/features/ui/pages/notifaction_screen/cubit/notification_view_model.dart';
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
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  final HomeTabViewModel viewModel = getIt<HomeTabViewModel>();
  final NotificationViewModel notificationViewModel = getIt<NotificationViewModel>();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    viewModel.loadHomeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserViewModel>().user?.id;
      if (userId != null && userId.isNotEmpty) {
        notificationViewModel.listenToNotifications(userId);
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    viewModel.close();
    super.dispose();
  }

  Future<void> _moveCameraToLocation(LatLng location) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel = context.read<UserViewModel>();
    final user = userViewModel.user;

    return BlocConsumer<HomeTabViewModel, HomeTabStates>(
      bloc: viewModel,
      listenWhen: (previous, current) {
        return previous.userLocation != current.userLocation ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        final location = state.userLocation;
        if (location != null) {
          _moveCameraToLocation(location);
        }

        final errorMessage = state.errorMessage;
        if (errorMessage != null && errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          viewModel.clearErrorMessage();
        }
      },
      builder: (context, state) {
        final address = state.userAddress ?? "Select Location";
        final location = state.userLocation ?? _defaultLocation;
        final featuredApartments = state.featuredApartments;
        final nearbyApartments = state.nearbyApartments;

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
                              backgroundColor: Colors.white,
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
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: theme.highlightColor),
                            ),
                            child: Row(
                              children: [
                                Image.asset(AppAssets.locationIcon, width: 16.w),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                if (state.isLoadingLocation)
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
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
                        child: BlocBuilder<NotificationViewModel, NotificationStates>(
                          bloc: notificationViewModel,
                          builder: (context, notificationState) {
                            final unreadCount = notificationState is NotificationLoaded
                                ? notificationState.unreadCount
                                : 0;
                            final hasNewNotification = unreadCount > 0;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(AppAssets.notification, width: 24.w),
                                if (hasNewNotification)
                                  Positioned(
                                    right: -8.w,
                                    top: -8.h,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minWidth: 18.w,
                                        minHeight: 18.h,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.redColor,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unreadCount > 99 ? '99+' : '$unreadCount',
                                        style: AppStyles.medium12White.copyWith(
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
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
                  SearchWidget(
                    hintText: "Search House, Apartment, etc",
                  ),
                  SizedBox(height: 20.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 170.h,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: location,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _moveCameraToLocation(location);
                        },
                        zoomControlsEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        scrollGesturesEnabled: true,
                        markers: state.userLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId("Current Location"),
                                  position: state.userLocation!,
                                ),
                              }
                            : {},
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text("Featured Estates", style: theme.textTheme.displaySmall),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.featuredEstateRoute);
                        },
                        child: Text("View all", style: theme.textTheme.displaySmall),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 185.h,
                    child: _buildFeaturedSection(
                      isLoading: state.isLoadingEstates,
                      apartments: featuredApartments,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text("Top Location", style: theme.textTheme.displaySmall),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.topLocationRoute);
                        },
                        child: Text("View all", style: theme.textTheme.displaySmall),
                      ),
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
                            color: theme.disabledColor,
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
                                  style: theme.textTheme.labelMedium,
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
                      Text("Nearby Estate", style: theme.textTheme.displaySmall),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.nearbyEstateRoute);
                        },
                        child: Text("View all", style: theme.textTheme.displaySmall),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 285.h,
                    child: _buildNearbySection(
                      isLoading: state.isLoadingEstates,
                      apartments: nearbyApartments,
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

  Widget _buildFeaturedSection({
    required bool isLoading,
    required List apartments,
  }) {
    if (isLoading && apartments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (apartments.isEmpty) {
      return const Center(child: Text("No featured estates available"));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: apartments.length,
      separatorBuilder: (_, __) => SizedBox(width: 10.w),
      itemBuilder: (_, index) {
        return FeaturedEstatesCard(apartment: apartments[index]);
      },
    );
  }

  Widget _buildNearbySection({
    required bool isLoading,
    required List apartments,
  }) {
    if (isLoading && apartments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (apartments.isEmpty) {
      return const Center(child: Text("No nearby estates available"));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: apartments.length,
      separatorBuilder: (_, __) => SizedBox(width: 10.w),
      itemBuilder: (_, index) {
        return NearbyEstateCard(apartment: apartments[index]);
      },
    );
  }
}
