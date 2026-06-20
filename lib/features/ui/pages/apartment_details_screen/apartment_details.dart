import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_states.dart';
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_view_model.dart';
import 'package:sokon/features/ui/widgets/app_video_player.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';

import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../core/utils/app_assets.dart';

class ApartmentDetails extends StatefulWidget {
  const ApartmentDetails({super.key});

  @override
  State<ApartmentDetails> createState() => _ApartmentDetailsState();
}

class _ApartmentDetailsState extends State<ApartmentDetails> {
  final ApartmentDetailsViewModel viewModel = getIt<ApartmentDetailsViewModel>();
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final apartment = ModalRoute.of(context)!.settings.arguments as Apartment;
      viewModel.initApartment(apartment);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);

    return BlocBuilder<ApartmentDetailsViewModel, ApartmentDetailsStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Builder(
              builder: (context) {
                if (state is ApartmentDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ApartmentDetailsError) {
                  return Center(child: Text(state.message));
                } else if (state is ApartmentDetailsSuccess) {
                  final apartment = state.apartment;
                  bool canRent = viewModel.canUserRent(userViewModel.user?.id, userViewModel.user?.role);

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        buildVideoPlayer(apartment),
                        SizedBox(height: 20.h),
                        Text(
                          apartment.name ?? "Apartment",
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: 10.h),
                        _buildCapacityBanner(apartment, theme),
                        SizedBox(height: 16.h),
                        _buildLocationSection(apartment),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            propertyDetailsColumn(
                              name: "Bedrooms",
                              imageName: AppAssets.bedroomsIcon,
                              value: "${apartment.bedrooms ?? 0}",
                            ),
                            propertyDetailsColumn(
                              name: "Bathrooms",
                              imageName: AppAssets.bathroomsIcon,
                              value: "${apartment.bathrooms ?? 0}",
                            ),
                            propertyDetailsColumn(
                              name: "Living Rooms",
                              imageName: AppAssets.livingRoomsIcon,
                              value: "${apartment.livingRooms ?? 0}",
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text("Description", style: theme.textTheme.headlineMedium),
                            const Spacer(),
                            Image.asset(AppAssets.yesIcon, width: 18.w),
                            SizedBox(width: 5.w),
                            Text("Verified", style: theme.textTheme.displaySmall),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        ReadMoreText(
                          apartment.description ?? "No description available.",
                          trimLength: 150,
                          style: theme.textTheme.bodyMedium,
                          trimMode: TrimMode.Length,
                          colorClickableText: AppColors.redColor,
                          trimCollapsedText: 'Read more',
                          trimExpandedText: '  Read less',
                          moreStyle: AppStyles.bold12Primary,
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.disabledColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25.r,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: (apartment.ownerPhotoUrl != null &&
                                          apartment.ownerPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(apartment.ownerPhotoUrl!)
                                      : AssetImage(AppAssets.profileImage) as ImageProvider,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apartment.ownerName ?? "Owner",
                                        style: theme.textTheme.labelMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text("Professional Owner",
                                          style: theme.textTheme.displaySmall),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                InkWell(
                                  onTap: () {},
                                  child: Image.asset(AppAssets.callIcon, width: 32.w),
                                ),
                                SizedBox(width: 10.w),
                                if (canRent)
                                  InkWell(
                                    onTap: () {
                                      if (apartment.ownerId != null) {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.chatRoute,
                                          arguments: {
                                            'receiverId': apartment.ownerId,
                                            'receiverName': apartment.ownerName ?? "Owner",
                                            'receiverPhotoUrl': apartment.ownerPhotoUrl,
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Owner contact information not available")),
                                        );
                                      }
                                    },
                                    child: Image.asset(AppAssets.messageIcon, width: 32.w),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text("Gallery", style: theme.textTheme.headlineMedium),
                        Text("Take a look inside", style: theme.textTheme.bodyMedium),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 110.h,
                          child: (apartment.images == null || apartment.images!.isEmpty)
                              ? const Center(child: Text("No images available"))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: apartment.images!.length > 3
                                      ? 3
                                      : apartment.images!.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: 15.w),
                                  itemBuilder: (context, index) {
                                    final bool isLast =
                                        index == 2 && apartment.images!.length > 3;

                                    return InkWell(
                                      onTap: () => openFullScreenGallery(apartment, index),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.r),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              apartment.images![index],
                                              width: 100.w,
                                              height: 110.h,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Image.asset(AppAssets.imageC,
                                                      width: 100.w,
                                                      height: 110.h,
                                                      fit: BoxFit.cover),
                                          ),
                                            if (isLast)
                                              Container(
                                                width: 100.w,
                                                height: 110.h,
                                                color: Colors.black.withOpacity(0.5),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "+${apartment.images!.length - 2}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: 30.h),
                        if (canRent)
                          CustomElevatedButtom(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.bookingRoute, arguments: apartment);
                            },
                            text: apartment.availablePeople == 0
                                ? "Fully Booked"
                                : "Rent Now",
                            width: 500.w,
                            customPadding: 16.h,
                            borderRadius: 12.r,
                            backgroundColorElevated: AppColors.darkBlueColor,
                            textStyle: AppStyles.semiBold20White,
                          ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
            ),
          ),
        );
      },
    );
  }

  Widget propertyDetailsColumn({
    required String imageName,
    required String name,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageName, width: 20.w, fit: BoxFit.contain),
          SizedBox(width: 4.w),
          Text(value, style: theme.textTheme.bodyMedium),
          SizedBox(width: 2.w),
          Flexible(
            child: AutoSizeText(
              name,
              maxLines: 1,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void openFullScreenGallery(Apartment apartment, int initialIndex) {
    if (apartment.images == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text("${initialIndex + 1} / ${apartment.images!.length}"),
          ),
          body: PhotoViewGallery.builder(
            itemCount: apartment.images!.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(apartment.images![index]),
                minScale: PhotoViewComputedScale.contained,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget buildVideoPlayer(Apartment apartment) {
    if (apartment.videoUrl == null || apartment.videoUrl!.isEmpty) {
      return Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: const Center(child: Text("No video available")),
      );
    }

    return AppVideoPlayer.network(
      apartment.videoUrl!,
      height: 220.h,
      borderRadius: BorderRadius.circular(24.r),
    );
  }

  Widget _buildLocationSection(Apartment apartment) {
    final theme = Theme.of(context);
    final hasManualAddress =
        apartment.address != null && apartment.address!.trim().isNotEmpty;
    final hasMapAddress = apartment.locationAddress != null &&
        apartment.locationAddress!.trim().isNotEmpty;
    final hasCoordinates = apartment.lat != null && apartment.lng != null;
    final displayedAddress = hasManualAddress
        ? apartment.address!
        : hasMapAddress
            ? apartment.locationAddress!
            : 'Address picker';
    final canOpenMap = hasMapAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCoordinates) ...[
          SizedBox(
            height: 220.h,
            width: double.infinity,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.grayColor.withOpacity(0.2),
                ),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(apartment.lat!, apartment.lng!),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('apartment_location'),
                    position: LatLng(apartment.lat!, apartment.lng!),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                compassEnabled: false,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
        Text("Address", style: theme.textTheme.headlineMedium),
        SizedBox(height: 6.h),
        Text(
          displayedAddress,
          style: theme.textTheme.bodyMedium,
        ),
        if (displayedAddress == 'Address picker') ...[
          SizedBox(height: 4.h),
          Text(
            "Owner did not add an address yet.",
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (canOpenMap) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 42.h,
            child: OutlinedButton.icon(
              onPressed: () => _openInGoogleMaps(
                lat: apartment.lat ?? 0,
                lng: apartment.lng ?? 0,
                address: apartment.locationAddress!,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(
                  color: AppColors.primaryColor.withOpacity(0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              icon: Icon(Icons.map_outlined, size: 18.sp),
              label: Text(
                "Open in Map",
                style: theme.textTheme.displaySmall,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
        Align(
          alignment: Alignment.centerRight,
          child: _buildPriceText(apartment),
        ),
      ],
    );
  }

  Widget _buildPriceText(Apartment apartment) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "EG ${apartment.price ?? 0}/",
            style: theme.textTheme.labelMedium,
          ),
          TextSpan(text: "month", style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildCapacityBanner(Apartment apartment, ThemeData theme) {
    final maxPeople = apartment.maxPeople ?? 1;
    final availablePeople = apartment.availablePeople ?? maxPeople;
    final occupiedPeople = maxPeople - availablePeople;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: theme.primaryColor.withOpacity(isDark ? 0.32 : 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.groups_rounded, color: theme.primaryColor, size: 28.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Living Capacity", style: theme.textTheme.labelMedium),
                SizedBox(height: 4.h),
                Text(
                  "$availablePeople of $maxPeople people available",
                  style: theme.textTheme.bodyMedium,
                ),
                if (occupiedPeople > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    "$occupiedPeople ${occupiedPeople == 1 ? 'person is' : 'people are'} already renting here",
                    style: theme.textTheme.displaySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInGoogleMaps({
    required double lat,
    required double lng,
    required String address,
  }) async {
    final hasAddress = address.trim().isNotEmpty && address != 'Address picker';
    final target = hasAddress
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
          );

    if (!await launchUrl(target, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }
}
