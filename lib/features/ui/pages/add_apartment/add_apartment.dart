import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:video_player/video_player.dart';
//
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../core/cache/provider/location_provider.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_routes.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_text_form_field.dart';

class AddApartment extends StatefulWidget {
  const AddApartment({super.key});

  @override
  State<AddApartment> createState() => _AddApartmentState();
}

class _AddApartmentState extends State<AddApartment> {
  VideoPlayerController? _controllerVideo;
 // ImagePicker? _controllerImage;

  final ImagePicker _videoPicker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();

  late List<File> apartmentImages;
  int bedrooms = 0;
  int bathrooms = 0;
  int livingRooms = 0;
  TextEditingController descriptionCRl=TextEditingController(text: "");
  TextEditingController priceCRl=TextEditingController(text: "");

  late LocationProvider  locationProvider;


  @override
  void initState() {
    super.initState();
    apartmentImages = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .clearEventLocation();
    });
  }

  Future<void> pickVideo(ImageSource source) async {
    await _requestPermission(source);
    final XFile? video = await _videoPicker.pickVideo(
      source: source,
      maxDuration: source == ImageSource.camera
          ? const Duration(minutes: 10)
          : null,
    );
    if (video == null) return;
    final controller = VideoPlayerController.file(File(video.path));
    try {
      await controller.initialize();

      if (controller.value.duration > const Duration(minutes: 10)) {
        controller.dispose();
        _showError("The video duration should not exceed 10 minutes.");
        return;
      }
      _controllerVideo?.dispose();
      _controllerVideo = controller;
      setState(() {});
    } catch (e) {
      controller.dispose();
      _showError("Video playback failed");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    await _requestPermission(source);

    final XFile? pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        apartmentImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.storage.request();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
     locationProvider=Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Apartment", style: AppStyles.bold20black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    height: 220.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.sp),
                    ),
                    child:
                        _controllerVideo != null &&
                            _controllerVideo!.value.isInitialized
                        ? Center(
                            child: AspectRatio(
                              aspectRatio: _controllerVideo!.value.aspectRatio,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controllerVideo!.value.size.width,
                                    height: _controllerVideo!.value.size.height,
                                    child: VideoPlayer(_controllerVideo!),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        pickVideo(ImageSource.camera),
                                    icon: Icon(Icons.videocam),
                                    label: Text("Camera"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        pickVideo(ImageSource.gallery),
                                    icon: Icon(Icons.video_library),
                                    label: Text("Gallery"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  if (_controllerVideo != null)
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

                  if (_controllerVideo != null &&
                      _controllerVideo!.value.isInitialized)
                    Positioned(
                      bottom: 12.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
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
              ),
              SizedBox(height: 20.h),
              Text("Sky Dandelions Apartment:", style: AppStyles.bold20black),
              SizedBox(height: 5.h),

              Row(
                children: [
                  InkWell(onTap: () => Navigator.pushNamed(context, AppRoutes.locationPickerRoute),
                      child: Image.asset(AppAssets.locationIcon, width: 14.w)),
                  SizedBox(width: 4.w),
                  Expanded(
                    child:
                    AutoSizeText(maxLines: 10,
                      locationProvider.eventAddress==null ?
                       "Select Location"                          :
                      "${locationProvider.eventAddress}",
                      style: AppStyles.medium10blueDarkColor ,

                      ),

                    // Text(
                    //   locationProvider.eventAddress! ?? "Select Location",
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: AppStyles.medium10blueDarkColor,
                    // ),
                  ),
                  Expanded(
                    child: CustomTextFormField(controller: priceCRl,
                      maxLines: 1,
                      borderRadius: 50,
                        suffixIconName: Icon(Icons.attach_money_outlined,color: AppColors.primaryColor,),
                        paddingHorizontal: 5.w,
                        paddingVertical: 0.h
                      ,hintText:"Enter price",
                      borderSideColor: AppColors.transparentColor,
                      keyboardType: TextInputType.number,
                      hintStyle: AppStyles.bold12Primary,
                      validator: (text) {
                        if (text==null || text.trim().isEmpty) {
                          return "Please enter a price";
                        }
                        return null;
                      },
                    ),
                  ),


                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: " EG/ month", style: AppStyles.bold12Primary),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Description:", style: AppStyles.medium16black),
              CustomTextFormField(controller: descriptionCRl,
                maxLines: 4
                ,hintText:"Enter Apartment Description",
                borderSideColor: AppColors.transparentColor,
                validator: (text) {
                  if (text==null || text.trim().isEmpty) {
                      return "Please enter a description";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.h),
              Text("Property Photos:", style: AppStyles.medium16black),
              SizedBox(height: 5.h),
              Row(
                children: [
                  apartmentImages.isNotEmpty
                      ? SizedBox(
                          height: 115.h,
                          width: 250.w,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: apartmentImages.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => openFullScreenGallery(index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    apartmentImages[index],
                                    width: 120.w,
                                    height: 100.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text("Camera"),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text("Gallery"),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(AppAssets.cameraIcon),
                            SizedBox(width: 5.w),
                            Text("Add Photos", style: AppStyles.medium13blue),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 90.h,
                          width: 90.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.white,
                          ),
                          child: Center(
                            child: Image.asset(AppAssets.cameraIconGray),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text("Property Details:", style: AppStyles.medium16black),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  propertyDetailsColumn(
                    name: "Bedrooms",
                    imageName: AppAssets.bedroomsIcon,
                    value: bedrooms,
                    onIncrease: () {
                      setState(() => bedrooms++);
                    },
                    onDecrease: () {
                      if (bedrooms > 0) {
                        setState(() => bedrooms--);
                      }
                    },
                  ),
                  propertyDetailsColumn(
                    name: "Bathrooms",
                    imageName: AppAssets.bathroomsIcon,
                    value: bathrooms,
                    onIncrease: () {
                      setState(() => bathrooms++);
                    },
                    onDecrease: () {
                      if (bathrooms > 0) {
                        setState(() => bathrooms--);
                      }
                    },
                  ),
                  propertyDetailsColumn(
                    name: "Living Rooms",
                    imageName: AppAssets.livingRoomsIcon,
                    value: livingRooms,
                    onIncrease: () {
                      setState(() => livingRooms++);
                    },
                    onDecrease: () {
                      if (livingRooms > 0) {
                        setState(() => livingRooms--);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: CustomElevatedButtom(
                  onPressed: () {
                    AlertDialogUtils.showMessage(
                      context: context,
                      posAction: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.homeScreenRoute, (route) => false,);
                      },
                      navAction: () {
                        Navigator.of(context).pop();
                      },
                      msg: "Apartment added successfully :",
                      nav: Container(
                        width: 100.w,
                        height: 50.h,

                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Edit",
                            style: AppStyles.semiBold20White,
                          ),
                        ),
                      ),
                      pos: Container(
                        width: 100.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Done",
                            style: AppStyles.semiBold20White,
                          ),
                        ),
                      ),
                    );

                  },
                  text: "Confirm",
                  width: 327.w,
                  borderRadius: 10,
                  backgroundColorElevated: AppColors.darkBlueColor,
                  textStyle: AppStyles.semiBold20White,
                ),
              ),
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

  Column propertyDetailsColumn({
    required String imageName,
    required int value,
    required String name,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageName),
            SizedBox(width: 5.w),
            Column(
              children: [
                IconButton(
                  onPressed: onIncrease,
                  icon: Icon(
                    Icons.arrow_circle_up_rounded,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  ),
                ),
                Text("$value", style: AppStyles.medium16black),
                IconButton(
                  onPressed: onDecrease,
                  icon: Icon(
                    Icons.arrow_circle_down_rounded,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 3.h),
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
                imageProvider: FileImage(apartmentImages[index]),
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
}
