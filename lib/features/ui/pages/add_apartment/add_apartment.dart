import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:video_player/video_player.dart';
//
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../cloudinary_service.dart';
import '../../../../core/cache/provider/location_provider.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../firebase_utils.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_text_form_field.dart';

class AddApartment extends StatefulWidget {
  const AddApartment({super.key});

  @override
  State<AddApartment> createState() => _AddApartmentState();
}

class _AddApartmentState extends State<AddApartment> {
  VideoPlayerController? _controllerVideo;

  final ImagePicker _videoPicker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();

  late List<File> apartmentImages;
  int bedrooms = 0;
  int bathrooms = 0;
  int livingRooms = 0;
  final TextEditingController nameCRl = TextEditingController();
  final TextEditingController descriptionCRl = TextEditingController();
  final TextEditingController priceCRl = TextEditingController();

  late LocationProvider locationProvider;
  List<String> imageUrls = [];
  String? videoUrl;
  File? videoFile;

  @override
  void initState() {
    super.initState();
    apartmentImages = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).clearEventLocation();
    });
  }

  Future<void> pickVideo(ImageSource source) async {
    await _requestPermission(source);

    final XFile? video = await _videoPicker.pickVideo(
      source: source,
      maxDuration: source == ImageSource.camera ? const Duration(minutes: 10) : null,
    );

    if (video == null) return;

    videoFile = File(video.path);

    final controller = VideoPlayerController.file(videoFile!);

    try {
      await controller.initialize();

      if (controller.value.duration > const Duration(minutes: 10)) {
        controller.dispose();
        videoFile = null;
        _showError("The video duration should not exceed 10 minutes.");
        return;
      }

      _controllerVideo?.dispose();
      _controllerVideo = controller;
      setState(() {});
    } catch (e) {
      controller.dispose();
      videoFile = null;
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
      await Permission.photos.request();
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

  Future<void> uploadApartment() async {
    try {
      if (nameCRl.text.isEmpty || priceCRl.text.isEmpty || descriptionCRl.text.isEmpty) {
        _showError("Please fill all fields");
        return;
      }

      if (apartmentImages.isEmpty) {
        _showError("Please add at least one image");
        return;
      }

      if (locationProvider.apartmentLocation == null) {
        _showError("Please select location");
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      imageUrls.clear();

      for (var image in apartmentImages) {
        String? url = await CloudinaryService.uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        } else {
          Navigator.pop(context);
          _showError("Failed to upload image");
          return;
        }
      }

      if (videoFile != null) {
        videoUrl = await CloudinaryService.uploadVideo(videoFile!);
        if (videoUrl == null) {
          Navigator.pop(context);
          _showError("Failed to upload video");
          return;
        }
      }

      Apartment apartment = Apartment(
        name: nameCRl.text,
        description: descriptionCRl.text,
        price: double.tryParse(priceCRl.text),
        images: imageUrls,
        videoUrl: videoUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        livingRooms: livingRooms,
        address: locationProvider.apartmentAddress,
        lat: locationProvider.apartmentLocation?.latitude,
        lng: locationProvider.apartmentLocation?.longitude,
      );

      await FireBaseUtils.addApartmentToFirestore(
        apartment,
        FirebaseAuth.instance.currentUser!.uid,
      );

      if (mounted) Navigator.pop(context);

      AlertDialogUtils.showMessage(
        context: context,
        msg: "Apartment added successfully",
        title: "Success",
        pos: Icon(Icons.check_circle, color: AppColors.primaryColor),
        posAction: () {
          Navigator.of(context).pushNamed(AppRoutes.homeScreenRoute);
        },
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    locationProvider = Provider.of<LocationProvider>(context);
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.sp),
                    ),
                    child: _controllerVideo != null && _controllerVideo!.value.isInitialized
                        ? Center(
                            child: AspectRatio(
                              aspectRatio: _controllerVideo!.value.aspectRatio,
                              child: VideoPlayer(_controllerVideo!),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => pickVideo(ImageSource.camera),
                                    icon: const Icon(Icons.videocam),
                                    label: const Text("Camera"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => pickVideo(ImageSource.gallery),
                                    icon: const Icon(Icons.video_library),
                                    label: const Text("Gallery"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  if (_controllerVideo != null)
                    FloatingActionButton(
                      mini: true,
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white.withOpacity(0.5),
                      elevation: 0,
                      onPressed: () {
                        setState(() {
                          _controllerVideo!.value.isPlaying ? _controllerVideo!.pause() : _controllerVideo!.play();
                        });
                      },
                      child: Icon(
                        _controllerVideo!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.blackColor,
                        size: 30.r,
                      ),
                    ),
                  if (_controllerVideo != null && _controllerVideo!.value.isInitialized)
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
                          formatDuration(_controllerVideo!.value.duration),
                          style: AppStyles.medium12White,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Apartment Name:", style: AppStyles.medium16black),
              SizedBox(height: 5.h),
              CustomTextFormField(
                controller: nameCRl,
                hintText: "Enter Apartment Name",
                borderSideColor: AppColors.grayColor.withOpacity(0.3),
                validator: (text) => (text == null || text.trim().isEmpty) ? "Required" : null,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.locationPickerRoute),
                      child: Row(
                        children: [
                          Image.asset(AppAssets.locationIcon, width: 14.w),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: AutoSizeText(
                              locationProvider.apartmentAddress ?? "Select Location",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.medium10blueDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: CustomTextFormField(
                      controller: priceCRl,
                      maxLines: 1,
                      borderRadius: 50,
                      suffixIconName: Icon(Icons.attach_money_outlined, color: AppColors.primaryColor, size: 20.sp),
                      paddingHorizontal: 10.w,
                      paddingVertical: 0,
                      hintText: "Price",
                      borderSideColor: AppColors.grayColor.withOpacity(0.3),
                      keyboardType: TextInputType.number,
                      hintStyle: AppStyles.medium12gray,
                      validator: (text) => (text == null || text.trim().isEmpty) ? "Required" : null,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text("EG/mo", style: AppStyles.bold10Primary),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Description:", style: AppStyles.medium16black),
              SizedBox(height: 5.h),
              CustomTextFormField(
                controller: descriptionCRl,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                hintText: "Enter Apartment Description",
                borderSideColor: AppColors.grayColor.withOpacity(0.3),
                validator: (text) => (text == null || text.trim().isEmpty) ? "Required" : null,
              ),
              SizedBox(height: 20.h),
              Text("Property Photos:", style: AppStyles.medium16black),
              SizedBox(height: 10.h),
              Row(
                children: [
                  if (apartmentImages.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: apartmentImages.length,
                          separatorBuilder: (context, index) => SizedBox(width: 10.w),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => openFullScreenGallery(index),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  apartmentImages[index],
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Camera"),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Gallery"),
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
                            Image.asset(AppAssets.cameraIcon, width: 18.w),
                            SizedBox(width: 5.w),
                            Text("Add", style: AppStyles.medium13blue),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 70.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.offWhiteColor,
                            border: Border.all(color: AppColors.grayColor.withOpacity(0.3)),
                          ),
                          child: const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text("Property Details:", style: AppStyles.medium16black),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  propertyDetailsColumn(
                    name: "Bedrooms",
                    imageName: AppAssets.bedroomsIcon,
                    value: bedrooms,
                    onIncrease: () => setState(() => bedrooms++),
                    onDecrease: () { if (bedrooms > 0) setState(() => bedrooms--); },
                  ),
                  propertyDetailsColumn(
                    name: "Bathrooms",
                    imageName: AppAssets.bathroomsIcon,
                    value: bathrooms,
                    onIncrease: () => setState(() => bathrooms++),
                    onDecrease: () { if (bathrooms > 0) setState(() => bathrooms--); },
                  ),
                  propertyDetailsColumn(
                    name: "Living Rooms",
                    imageName: AppAssets.livingRoomsIcon,
                    value: livingRooms,
                    onIncrease: () => setState(() => livingRooms++),
                    onDecrease: () { if (livingRooms > 0) setState(() => livingRooms--); },
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Center(
                child: CustomElevatedButtom(
                  onPressed: uploadApartment,
                  text: "Confirm",
                  width: 500.w,
                  borderRadius: 10,
                  backgroundColorElevated: AppColors.darkBlueColor,
                  textStyle: AppStyles.semiBold20White,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerVideo?.dispose();
    nameCRl.dispose();
    descriptionCRl.dispose();
    priceCRl.dispose();
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imageName, width: 24.w),
            SizedBox(width: 8.w),
            Column(
              children: [
                InkWell(
                  onTap: onIncrease,
                  child: Icon(Icons.keyboard_arrow_up, color: AppColors.primaryColor, size: 24.sp),
                ),
                Text("$value", style: AppStyles.bold14Primary),
                InkWell(
                  onTap: onDecrease,
                  child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor, size: 24.sp),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(name, style: AppStyles.regular12gray),
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
            foregroundColor: Colors.white,
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
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
