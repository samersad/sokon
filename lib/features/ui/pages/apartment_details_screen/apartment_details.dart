import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:readmore/readmore.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:video_player/video_player.dart';

import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_routes.dart';
import '../../widgets/alert_dialog_utils.dart';

class ApartmentDetails extends StatefulWidget {
  const ApartmentDetails({super.key});

  @override
  State<ApartmentDetails> createState() => _ApartmentDetailsState();
}

class _ApartmentDetailsState extends State<ApartmentDetails> {
  VideoPlayerController? _controllerVideo;


  late List<String> apartmentImages;

  @override
  void initState() {
    super.initState();
    apartmentImages = [
      AppAssets.imageC,
      AppAssets.imageC,
      AppAssets.imageC,
      AppAssets.imageC,
      AppAssets.imageC,

    ];
    _controllerVideo =
    VideoPlayerController.networkUrl( Uri.parse( 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', ), )
      ..initialize().then((_) {
      setState(() {});
    });

  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50.h),
              buildVideoPlayer(),
              SizedBox(height: 20.h),
              Text("Sky Dandelions Apartment:", style: AppStyles.bold18PrimaryColor),
              SizedBox(height: 10.h),

              Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                    "Jakarta, Indonesia",
                      maxLines: 5,
                      style: AppStyles.medium16black,
                    ),
                  ),
                  Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "EG 290/",
                          style: AppStyles.medium16black,
                        ),
                        TextSpan(text: "month", style: AppStyles.bold10black),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  propertyDetailsColumn(
                      name: "Bedrooms",
                      imageName: AppAssets.bedroomsIcon,
                      value: "1"
                  ),
                  propertyDetailsColumn(
                    name: "Bathrooms",
                    imageName: AppAssets.bathroomsIcon,
                    value: "2",
                  ),
                  propertyDetailsColumn(
                    name: "Living Rooms",
                    imageName: AppAssets.livingRoomsIcon,
                    value: "3",
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Text("Description:", style: AppStyles.bold18PrimaryColor),
                  Spacer(),
                  Image.asset(AppAssets.yesIcon)  ,
                  SizedBox(width: 5.h),
                  Text("Verified:", style: AppStyles.medium16whiteBlue),

                ],
              ),
              SizedBox(height: 10.h),

              ReadMoreText(
                "Experience comfortable living at Sky Dandelions Apartment in Jakarta.This modern space offers 3 spacious bedrooms, 2 bathrooms, a bright living room with large windows, and a fully equipped kitchen Conveniently located near restaurants, shops, and public transport, it's perfect for short or long stays",
                trimLength: 150,
                style: AppStyles.medium13PrimaryColor,
                trimMode: TrimMode.Length,
                colorClickableText: AppColors.redColor,
                trimCollapsedText: 'Read more',
                trimExpandedText: '  Read less',
                moreStyle: AppStyles.bold12Primary,
              ),
              SizedBox(height: 10.h),

              Container(
              height: 80.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(39.sp),
              ),
              child:Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 54.r,backgroundColor: AppColors.transparentColor,
                      child: Image.asset(AppAssets.avatar,width: 64.w,height: 64.h,fit: BoxFit.cover,),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text("Emmett Perry", style: AppStyles.bold16PrimaryColor),
                        SizedBox(height: 5.h,),
                        Text("Owner", style: AppStyles.bold12PrimaryColor),


                      ],
                    ),
                    Spacer(),
                    Image.asset(AppAssets.callIcon),
                    SizedBox(width: 10.w,),
                    Image.asset(AppAssets.messageIcon),
                    SizedBox(width: 10.w,),
                  ],
                ),
              ),

                
            ),
              SizedBox(height: 10.h),

              Text("Gallery", style: AppStyles.bold18PrimaryColor),
              Text("Take a look inside", style: AppStyles.medium13Gray),
              SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: apartmentImages.length > 3
                          ? 3
                          : apartmentImages.length,
                      separatorBuilder: (context, index) => SizedBox(width: 20.w),
                      itemBuilder: (context, index) {
                        final bool isLast =
                            index == 2 && apartmentImages.length > 3;

                        return InkWell(
                          onTap: () => openFullScreenGallery(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.asset(
                                  apartmentImages[index],
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                ),

                                if (isLast)
                                  Container(
                                    width: 100.w,
                                    height: 100.h,
                                    color: Colors.black.withOpacity(0.5),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "+${apartmentImages.length - 2}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26.sp,
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
                ),
              ],
            ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomElevatedButtom(
                    onPressed: () {
                    },
                    text: "Buy Now",
                    width: 120.w,
                    customPadding: 10,
                    borderRadius: 25.r,
                    backgroundColorElevated: AppColors.darkBlueColor,
                    textStyle: AppStyles.semiBold20White,
                  ),
                  CustomElevatedButtom(
                    onPressed: () {
                    },
                    text: "Rent Now",
                    width: 120.w,
                    customPadding: 10,

                    borderRadius: 25.r,
                    backgroundColorElevated: AppColors.darkBlueColor,
                    textStyle: AppStyles.semiBold20White,
                  ),

                ],
              ),
              SizedBox(height: 30.h),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerVideo?.dispose();
    super.dispose();
  }

  Row propertyDetailsColumn({
    required String imageName,
    required String name,
    required String value,

  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imageName),
        SizedBox(width: 5.w),
        Text(value, style: AppStyles.medium13GrayWithOpacity),
        SizedBox(width: 3.h),
        Text(name, style: AppStyles.medium13GrayWithOpacity),

      ],
    );
  }

  void openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text("${initialIndex + 1} / ${apartmentImages.length}"),
          ),
          body: PhotoViewGallery.builder(
            itemCount: apartmentImages.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(apartmentImages[index]),
                minScale: PhotoViewComputedScale.contained,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
  Widget buildVideoPlayer() {
    if (_controllerVideo == null ||
        !_controllerVideo!.value.isInitialized) {
      return Container(
        height: 220.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(24.sp),
        ),
        child: const CircularProgressIndicator(),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24.sp),
          child: AspectRatio(
            aspectRatio: _controllerVideo!.value.aspectRatio,
            child: VideoPlayer(_controllerVideo!),
          ),
        ),
        FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(70),
            side: BorderSide(color: AppColors.blackColor, width: 4),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            setState(() {
              _controllerVideo!.value.isPlaying
                  ? _controllerVideo!.pause()
                  : _controllerVideo!.play();
            });
          },
          child: Icon(
            _controllerVideo!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: AppColors.blackColor,
            size: 40.r,
          ),
        ),
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formatDuration(_controllerVideo!.value.duration),
              style: AppStyles.medium12White,
            ),
          ),
        ),
      ],
    );
  }

}
