import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_states.dart';
import 'package:sokon/features/ui/pages/apartment_details_screen/cubit/apartment_details_view_model.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:video_player/video_player.dart';

import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../core/utils/app_assets.dart';

class ApartmentDetails extends StatefulWidget {
  const ApartmentDetails({super.key});

  @override
  State<ApartmentDetails> createState() => _ApartmentDetailsState();
}

class _ApartmentDetailsState extends State<ApartmentDetails> {
  VideoPlayerController? _controllerVideo;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final apartment = ModalRoute.of(context)!.settings.arguments as Apartment;
      context.read<ApartmentDetailsViewModel>().initApartment(apartment);
      
      if (apartment.videoUrl != null && apartment.videoUrl!.isNotEmpty) {
        _controllerVideo = VideoPlayerController.networkUrl(
          Uri.parse(apartment.videoUrl!),
        )..initialize().then((_) {
            setState(() {});
          });
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final viewModel = context.read<ApartmentDetailsViewModel>();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ApartmentDetailsViewModel, ApartmentDetailsStates>(
          builder: (context, state) {
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
                    buildVideoPlayer(apartment, viewModel),
                    SizedBox(height: 20.h),
                    Text(
                      "${apartment.name ?? "Apartment"}:",
                      style: AppStyles.bold18PrimaryColor,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            apartment.address ?? "No Address Provided",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.medium16black,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "EG ${apartment.price ?? 0}/",
                                style: AppStyles.medium16black,
                              ),
                              TextSpan(text: "month", style: AppStyles.bold10black),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        Text("Description:", style: AppStyles.bold18PrimaryColor),
                        const Spacer(),
                        Image.asset(AppAssets.yesIcon, width: 18.w),
                        SizedBox(width: 5.w),
                        Text("Verified:", style: AppStyles.medium16whiteBlue),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ReadMoreText(
                      apartment.description ?? "No description available.",
                      trimLength: 150,
                      style: AppStyles.medium13PrimaryColor,
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
                        color: Colors.black.withOpacity(0.05),
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
                                    style: AppStyles.bold16PrimaryColor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text("Professional Owner",
                                      style: AppStyles.bold12PrimaryColor),
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
                    Text("Gallery", style: AppStyles.bold18PrimaryColor),
                    Text("Take a look inside", style: AppStyles.medium13Gray),
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
                        text: "Rent Now",
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
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerVideo?.dispose();
    super.dispose();
  }

  Expanded propertyDetailsColumn({
    required String imageName,
    required String name,
    required String value,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageName, width: 20.w, fit: BoxFit.contain),
          SizedBox(width: 4.w),
          Text(value, style: AppStyles.medium10blueDarkColor),
          SizedBox(width: 2.w),
          Flexible(
            child: AutoSizeText(
              name,
              maxLines: 1,
              style: AppStyles.medium10blueDarkColor,
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

  Widget buildVideoPlayer(Apartment apartment, ApartmentDetailsViewModel viewModel) {
    if (apartment.videoUrl == null || apartment.videoUrl!.isEmpty) {
      return Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(24.r),
          image: apartment.images != null && apartment.images!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(apartment.images![0]), fit: BoxFit.cover)
              : null,
        ),
        child: const Icon(Icons.videocam_off, color: Colors.white, size: 50),
      );
    }

    if (_controllerVideo == null || !_controllerVideo!.value.isInitialized) {
      return Container(
        height: 220.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: AspectRatio(
            aspectRatio: _controllerVideo!.value.aspectRatio,
            child: VideoPlayer(_controllerVideo!),
          ),
        ),
        FloatingActionButton(
          mini: true,
          shape: const CircleBorder(),
          backgroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          onPressed: () {
            setState(() {
              _controllerVideo!.value.isPlaying
                  ? _controllerVideo!.pause()
                  : _controllerVideo!.play();
            });
          },
          child: Icon(
            _controllerVideo!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.blackColor,
            size: 30.r,
          ),
        ),
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              viewModel.formatDuration(_controllerVideo!.value.duration),
              style: AppStyles.medium12White,
            ),
          ),
        ),
      ],
    );
  }
}
