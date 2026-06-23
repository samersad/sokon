import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/constants/university_locations.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/notifaction_screen/cubit/notification_states.dart';
import 'package:sokon/features/ui/pages/notifaction_screen/cubit/notification_view_model.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_states.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/cubit/home_tab_view_model.dart';
import 'package:sokon/features/ui/pages/tabs/home_tab/home_map_screen.dart';

import '../../../../../core/utils/app_styles.dart';
import '../../../widgets/district_location_card.dart';
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

  Future<void> _openHomeMap({
    required HomeTabStates state,
    required String? userPhotoUrl,
  }) async {
    if (!mounted) return;

    Navigator.of(context).pushNamed(
      AppRoutes.homeMapRoute,
      arguments: HomeMapArguments(
        apartments: state.allApartments,
        userLocation: state.selectedUniversity.location,
        userPhotoUrl: userPhotoUrl,
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
        return previous.selectedUniversity != current.selectedUniversity ||
            previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        _moveCameraToLocation(state.selectedUniversity.location);

        final errorMessage = state.errorMessage;
        if (errorMessage != null && errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          viewModel.clearErrorMessage();
        }
      },
      builder: (context, state) {
        final universityLocation = state.selectedUniversity.location;
        final featuredApartments = state.featuredApartments;
        final nearbyApartments = state.nearbyApartments;
        final topDistricts = state.topDistricts;

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
                        child: _buildUniversitySelector(
                          theme: theme,
                          selectedUniversity: state.selectedUniversity,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 170.h,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: universityLocation,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _moveCameraToLocation(universityLocation);
                        },
                        zoomControlsEnabled: true,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        scrollGesturesEnabled: true,
                        markers: {
                          Marker(
                            markerId: const MarkerId("university_location"),
                            position: universityLocation,
                            infoWindow: InfoWindow(
                              title: state.selectedUniversity.name,
                            ),
                          ),
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoadingEstates
                          ? null
                          : () => _openHomeMap(
                                state: state,
                                userPhotoUrl: user?.photoUrl,
                              ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("View all apartments on map"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
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
                    height: 210.h,
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
                  if (state.isLoadingEstates && topDistricts.isEmpty)
                    SizedBox(
                      height: 60.h,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (topDistricts.isEmpty)
                    SizedBox(
                      height: 60.h,
                      child: Center(
                        child: Text(
                          "No districts available",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 78.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topDistricts.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, index) {
                          final district = topDistricts[index];
                          return SizedBox(
                            width: 138.w,
                            child: DistrictLocationCard(
                              districtSummary: district,
                              compact: true,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.districtApartmentsRoute,
                                  arguments: district,
                                );
                              },
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
                    height: 315.h,
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

  Widget _buildUniversitySelector({
    required ThemeData theme,
    required University selectedUniversity,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          context: context,
          builder: (_) => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      "Select your University to get the apartment near by your University ",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  ...UniversityLocations.all.map((university) {
                    final isSelected = university.name == selectedUniversity.name;
                    return ListTile(
                      leading: Icon(
                        Icons.school_rounded,
                        color: isSelected
                            ? AppColors.primaryColor
                            : theme.iconTheme.color,
                      ),
                      title: Text(
                        university.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryColor : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppColors.primaryColor)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        viewModel.selectUniversity(university);
                      },
                    );
                  }),
                ],
              ),
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
            Icon(Icons.school_rounded, size: 18.w, color: AppColors.primaryColor),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                selectedUniversity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Image.asset(AppAssets.downIcon, width: 14.w),
          ],
        ),
      ),
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
