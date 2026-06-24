import 'package:auto_size_text/auto_size_text.dart';
import 'package:sokon/l10n/app_localizations.dart';
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
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/data/repository/booking/repository/booking_repository.dart';
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
  final BookingRepository bookingRepository = getIt<BookingRepository>();
  bool isInitialized = false;
  bool canChat = false;
  bool isCheckingChatAccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final apartment = ModalRoute.of(context)!.settings.arguments as ApartmentResponse;
      viewModel.initApartment(apartment);
      _loadChatAccess(apartment);
      isInitialized = true;
    }
  }

  Future<void> _loadChatAccess(ApartmentResponse apartment) async {
    final userId = context.read<UserViewModel>().user?.id;
    if (userId == null || userId.isEmpty || apartment.id == null || apartment.id!.isEmpty) {
      return;
    }

    setState(() {
      isCheckingChatAccess = true;
    });

    try {
      final hasActiveBooking = await bookingRepository.hasActiveBookingForApartment(
        userId: userId,
        apartmentId: apartment.id!,
      );
      if (!mounted) return;
      setState(() {
        canChat = hasActiveBooking;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        canChat = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isCheckingChatAccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroMedia(apartment),
                        Transform.translate(
                          offset: Offset(0, -42.h),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                _buildTitleInfoCard(apartment, theme, l10n),
                                SizedBox(height: 18.h),
                                _buildUnverifiedWarning(apartment, theme, l10n),
                                _buildRatingRow(apartment, theme),
                                SizedBox(height: 18.h),
                                _buildCapacityBanner(apartment, theme, l10n),
                                SizedBox(height: 18.h),
                                _buildDescriptionSection(apartment, theme, l10n),
                                SizedBox(height: 22.h),
                                _buildLocationSection(apartment, l10n),
                                SizedBox(height: 22.h),
                                _buildOwnerCard(apartment, canRent, theme, l10n),
                                SizedBox(height: 22.h),
                                _buildGallerySection(apartment, theme, l10n),
                                SizedBox(height: 30.h),
                                if (canRent)
                                  CustomElevatedButtom(
                                    onPressed: apartment.availablePeople == 0
                                        ? () {}
                                        : () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.bookingRoute,
                                              arguments: apartment,
                                            );
                                          },
                                    text: apartment.availablePeople == 0
                                        ? l10n.fullyBooked
                                        : l10n.rentNow,
                                    width: 500.w,
                                    customPadding: 16.h,
                                    borderRadius: 19.r,
                                    backgroundColorElevated: apartment.availablePeople == 0
                                        ? AppColors.grayColor
                                        : theme.brightness == Brightness.dark
                                            ? AppColors.detailsVerifiedBlue
                                            : AppColors.darkBlueColor,
                                    textStyle: AppStyles.semiBold20White.copyWith(
                                      color: theme.brightness == Brightness.dark
                                          ? AppColors.darkPrimaryColor
                                          : AppColors.whiteColor,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                SizedBox(height: 30.h),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildHeroMedia(ApartmentResponse apartment) {
    return SizedBox(
      height: 330.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: buildVideoPlayer(apartment)),
          Positioned(
            top: 16.h,
            left: 16.w,
            child: Material(
              color: AppColors.darkGrayColor,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.whiteColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInfoCard(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor;
    final surfaceColor = isDark ? AppColors.darkPrimaryColor : AppColors.whiteColor;
    final borderColor = AppColors.detailsBorder.withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: isDark ? 0 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  apartment.name ?? "Apartment",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: titleColor,
                    fontFamily: AppStyles.inter,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _buildRatingChip(apartment, isDark),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: isDark ? AppColors.grayColor : AppColors.detailsMutedLight,
                size: 17.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  apartment.cityDistrictLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.grayColor : AppColors.detailsMutedLight,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 17.h),
          Divider(color: AppColors.detailsBorder.withValues(alpha: 0.2), height: 1),
          SizedBox(height: 17.h),
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.bed_rounded,
                value: "${apartment.bedrooms ?? 0}",
                label: l10n.bedrooms,
                theme: theme,
              ),
              SizedBox(width: 12.w),
              _buildInfoItem(
                icon: Icons.bathtub_rounded,
                value: "${apartment.bathrooms ?? 0}",
                label: l10n.bathrooms,
                theme: theme,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.meeting_room_rounded,
                value: "${apartment.livingRooms ?? 0}",
                label: l10n.livingRooms,
                theme: theme,
              ),
              SizedBox(width: 12.w),
              _buildInfoItem(
                icon: Icons.layers_rounded,
                value: "${apartment.floor ?? 1}",
                label: apartment.floorLabel,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(ApartmentResponse apartment, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.detailsDarkAccentStrong : AppColors.detailsLightAccentSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: isDark ? AppColors.detailsAccentTextDark : AppColors.detailsLightAccentText,
            size: 15.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            apartment.ratingLabel,
            style: TextStyle(
              color: isDark ? AppColors.detailsAccentTextDark : AppColors.detailsLightAccentText,
              fontFamily: AppStyles.inter,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimaryColor : AppColors.detailsLightBlueSurface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.detailsBodyDark : AppColors.detailsBodyLight,
                    fontFamily: AppStyles.inter,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                AutoSizeText(
                  label,
                  maxLines: 1,
                  minFontSize: 8,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grayColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(ApartmentResponse apartment, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final rating = apartment.ratingAverage ?? 0;
    final fullStars = rating.floor().clamp(0, 5);
    final hasHalfStar = rating - fullStars >= 0.5 && fullStars < 5;
    final reviewCount = apartment.ratingCount ?? 0;

    return Row(
      children: [
        Text(
          apartment.ratingLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.detailsBodyDark : AppColors.detailsBodyLight,
            fontFamily: AppStyles.inter,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 10.w),
        Row(
          children: List.generate(5, (index) {
            final icon = index < fullStars
                ? Icons.star_rounded
                : index == fullStars && hasHalfStar
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded;
            return Icon(icon, size: 18.sp, color: AppColors.starColor);
          }),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            "($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})",
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.grayColor,
              fontFamily: AppStyles.inter,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildVerificationBadge(apartment, theme, l10n),
            _buildPriceChip(apartment, theme),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          l10n.aboutThisApartment,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: isDark ? AppColors.detailsBodyDark : AppColors.detailsBodyLight,
            fontFamily: AppStyles.inter,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ReadMoreText(
          apartment.description ?? l10n.noDescription,
          trimLength: 180,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.detailsMutedDark : AppColors.detailsMutedLight,
            fontFamily: AppStyles.inter,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
          trimMode: TrimMode.Length,
          colorClickableText: AppColors.redColor,
          trimCollapsedText: ' Read more',
          trimExpandedText: ' Read less',
          moreStyle: AppStyles.bold12Primary.copyWith(
            color: isDark ? AppColors.whiteBlue : AppColors.primaryColor,
          ),
          lessStyle: AppStyles.bold12Primary.copyWith(
            color: isDark ? AppColors.whiteBlue : AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChip(ApartmentResponse apartment, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.detailsChipDark : AppColors.offWhiteColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "EG ${apartment.price?.toStringAsFixed(0) ?? '0'}/month",
        style: TextStyle(
          color: isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor,
          fontFamily: AppStyles.inter,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildOwnerCard(ApartmentResponse apartment, bool canRent, ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.detailsChipDark : AppColors.offWhiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26.r),
          topRight: Radius.circular(39.r),
          bottomLeft: Radius.circular(39.r),
          bottomRight: Radius.circular(39.r),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27.r,
            backgroundColor: AppColors.disabledGrayColor,
            backgroundImage:
                (apartment.ownerPhotoUrl != null && apartment.ownerPhotoUrl!.isNotEmpty)
                    ? NetworkImage(apartment.ownerPhotoUrl!)
                    : AssetImage(AppAssets.profileImage) as ImageProvider,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apartment.ownerName ?? l10n.owner,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  l10n.owner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (canRent && canChat && !isCheckingChatAccess)
            IconButton(
              onPressed: () => _openChat(apartment),
              icon: Image.asset(AppAssets.messageIcon, width: 28.w),
            ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final images = apartment.images ?? [];
    final visibleCount = images.length > 4 ? 4 : images.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gallery,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.takeLookInside,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.grayColor,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 82.h,
          child: images.isEmpty
              ? Center(
                  child: Text(
                    "No images available",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grayColor,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleCount,
                  separatorBuilder: (context, index) => SizedBox(width: 14.w),
                  itemBuilder: (context, index) {
                    final isLast = index == visibleCount - 1 && images.length > visibleCount;
                    return InkWell(
                      onTap: () => openFullScreenGallery(apartment, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Stack(
                          children: [
                            Image.network(
                              images[index],
                              width: 82.w,
                              height: 82.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                AppAssets.imageC,
                                width: 82.w,
                                height: 82.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (isLast)
                              Container(
                                width: 82.w,
                                height: 82.h,
                                color: AppColors.darkGrayColor,
                                alignment: Alignment.center,
                                child: Text(
                                  "+${images.length - visibleCount + 1}",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
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
      ],
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

  void openFullScreenGallery(ApartmentResponse apartment, int initialIndex) {
    if (apartment.images == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.pureBlack,
          appBar: AppBar(
            backgroundColor: AppColors.pureBlack,
            foregroundColor: AppColors.whiteColor,
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
            backgroundDecoration: const BoxDecoration(color: AppColors.pureBlack),
          ),
        ),
      ),
    );
  }

  Widget buildVideoPlayer(ApartmentResponse apartment) {
    final l10n = AppLocalizations.of(context)!;
    if (apartment.videoUrl == null || apartment.videoUrl!.isEmpty) {
      return Container(
        height: 330.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.disabledGrayColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
        ),
        child: Center(child: Text(l10n.noVideoAvailable)),
      );
    }

    return AppVideoPlayer.network(
      apartment.videoUrl!,
      height: 330.h,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24.r),
        bottomRight: Radius.circular(24.r),
      ),
    );
  }

  Widget _buildLocationSection(ApartmentResponse apartment, AppLocalizations l10n) {
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
            : 'No detailed address provided';
    final canOpenMap = hasMapAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          apartment.cityDistrictLabel,
          style: theme.textTheme.displaySmall,
        ),
        SizedBox(height: 6.h),
        if (hasCoordinates) ...[
          SizedBox(
            height: 220.h,
            width: double.infinity,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.grayColor.withValues(alpha: 0.2),
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
        Text(l10n.address, style: theme.textTheme.headlineMedium),
        SizedBox(height: 6.h),
        Text(
          displayedAddress,
          style: theme.textTheme.bodyMedium,
        ),
        if (displayedAddress == 'No detailed address provided') ...[
          SizedBox(height: 4.h),
          Text(
            l10n.ownerNoAddress,
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
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              icon: Icon(Icons.map_outlined, size: 18.sp),
              label: Text(
                l10n.openInMap,
                style: theme.textTheme.displaySmall,
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildCapacityBanner(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    final maxPeople = apartment.maxPeople ?? 1;
    final availablePeople = apartment.availablePeople ?? maxPeople;
    final normalizedAvailable = availablePeople.clamp(0, maxPeople);
    final occupiedPeople = (maxPeople - normalizedAvailable).clamp(0, maxPeople);
    final progress = maxPeople == 0 ? 0.0 : normalizedAvailable / maxPeople;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.addApartmentDarkField : AppColors.detailsChipLight;
    final trackColor = isDark ? AppColors.darkPrimaryColor : AppColors.whiteColor;
    final fillColor = isDark ? AppColors.detailsDarkAccent : AppColors.primaryColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(21.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.detailsBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.livingCapacity,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.detailsBodyDark : AppColors.detailsBodyLight,
                        fontFamily: AppStyles.inter,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$normalizedAvailable of $maxPeople people available",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.detailsMutedDark : AppColors.detailsMutedLight,
                        fontFamily: AppStyles.inter,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.detailsAccentTextDark.withValues(alpha: 0.1)
                      : AppColors.detailsLightAccentText.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.groups_rounded, color: fillColor, size: 26.sp),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12.h,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(fillColor),
            ),
          ),
          if (occupiedPeople > 0) ...[
            SizedBox(height: 12.h),
            Text(
              "$occupiedPeople ${occupiedPeople == 1 ? 'person is' : 'people are'} already renting here",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.detailsMutedDark : AppColors.detailsMutedLight,
                fontFamily: AppStyles.inter,
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    final isVerified = apartment.verified == true;
    final backgroundColor = isVerified
        ? AppColors.primaryColor.withValues(alpha: 0.10)
        : AppColors.grayColor.withValues(alpha: 0.10);
    final textColor = isVerified ? AppColors.primaryColor : AppColors.grayColor;
    final icon = isVerified ? Icons.verified_rounded : Icons.verified_outlined;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isVerified && theme.brightness == Brightness.dark
              ? AppColors.whiteColor
              : AppColors.transparentColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            isVerified ? l10n.verified : "Not verified",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontFamily: AppStyles.inter,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(ApartmentResponse apartment) {
    final l10n = AppLocalizations.of(context)!;
    if (apartment.ownerId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatRoute,
        arguments: {
          'receiverId': apartment.ownerId,
          'receiverName': apartment.ownerName ?? l10n.owner,
          'receiverPhotoUrl': apartment.ownerPhotoUrl,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ownerContactNotAvailable)),
      );
    }
  }

  Future<void> _openInGoogleMaps({
    required double lat,
    required double lng,
    required String address,

  }) async {
    final l10n = AppLocalizations.of(context)!;
    final hasAddress =
        address.trim().isNotEmpty && address != 'No detailed address provided';
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
        SnackBar(content: Text(l10n.couldNotOpenGoogleMaps)),
      );
    }
  }

  Widget _buildUnverifiedWarning(ApartmentResponse apartment, ThemeData theme, AppLocalizations l10n) {
    if (apartment.verified == true) {
      return const SizedBox.shrink();
    }
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.warningColor.withValues(alpha: 0.15) 
            : AppColors.warningColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.warningColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? AppColors.warningColor : const Color(0xFFD48D00),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notVerified,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.warningColor : const Color(0xFFB57800),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.notVerifiedBanner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.detailsBodyDark : AppColors.detailsMutedLight,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
