import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_states.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_view_model.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:video_player/video_player.dart';

import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../core/cache/cubit_manger/location_states.dart';
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
  bool _isLoadingDialogShowing = false;
  final AddApartmentViewModel viewModel = getIt<AddApartmentViewModel>();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Apartment", style: AppStyles.bold20black),
          centerTitle: true,
        ),
        body: BlocListener<AddApartmentViewModel, AddApartmentStates>(
          listener: (context, state) {
            if (state is AddApartmentLoading) {
              _isLoadingDialogShowing = true;
              AlertDialogUtils.showLoading(context: context, msg: "Uploading...");
            } else if (state is AddApartmentProgress) {
              AlertDialogUtils.hideLoading(context: context);
              AlertDialogUtils.showLoading(context: context, msg: state.message);
            } else if (state is AddApartmentError) {
              if (_isLoadingDialogShowing) {
                _isLoadingDialogShowing = false;
                AlertDialogUtils.hideLoading(context: context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is AddApartmentSuccess) {
              if (_isLoadingDialogShowing) {
                _isLoadingDialogShowing = false;
                AlertDialogUtils.hideLoading(context: context);
              }
              AlertDialogUtils.showMessage(
                context: context,
                msg: "Apartment added successfully",
                title: "Success",
                pos:Center(
                  child: Row(
                    children: [
                      Text("OK", style: AppStyles.bold14Primary),
                      SizedBox(width: 5.w),
                      Icon(Icons.check, color: AppColors.primaryColor, size: 20.sp)
                    ],
                  ),
                ),
                posAction: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.homeScreenRoute,
                        (route) => false,
                  );
                },
              );
            }
          },
          child: BlocBuilder<AddApartmentViewModel, AddApartmentStates>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Video Section
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
                            child: viewModel.controllerVideo != null && viewModel.controllerVideo!.value.isInitialized
                                ? Center(
                              child: AspectRatio(
                                aspectRatio: viewModel.controllerVideo!.value.aspectRatio,
                                child: VideoPlayer(viewModel.controllerVideo!),
                              ),
                            )
                                : Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => viewModel.pickVideo(ImageSource.camera),
                                      icon: const Icon(Icons.videocam),
                                      label: const Text("Camera"),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => viewModel.pickVideo(ImageSource.gallery),
                                      icon: const Icon(Icons.video_library),
                                      label: const Text("Gallery"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (viewModel.controllerVideo != null)
                            FloatingActionButton(
                              mini: true,
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white.withOpacity(0.5),
                              elevation: 0,
                              onPressed: () => viewModel.toggleVideoPlay(),
                              child: Icon(
                                viewModel.controllerVideo!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.blackColor,
                                size: 30.r,
                              ),
                            ),
                          if (viewModel.controllerVideo != null && viewModel.controllerVideo!.value.isInitialized)
                            Positioned(
                              bottom: 12.h,
                              right: 12.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8.r)),
                                child: Text(
                                  viewModel.formatDuration(viewModel.controllerVideo!.value.duration),
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
                        controller: viewModel.nameCRl,
                        hintText: "Enter Apartment Name",
                        borderSideColor: AppColors.grayColor.withOpacity(0.3),
                      ),
                      SizedBox(height: 20.h),

                      /// Location and Price
                      BlocBuilder<LocationViewModel, LocationState>(
                        builder: (context, state) {
                          var locationViewModel = context.read<LocationViewModel>();
                          return Row(
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
                                          locationViewModel.apartmentAddress ?? "Select Location",
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
                                  controller: viewModel.priceCRl,
                                  maxLines: 1,
                                  borderRadius: 50,
                                  suffixIconName: Icon(Icons.attach_money_outlined,
                                      color: AppColors.primaryColor, size: 20.sp),
                                  paddingHorizontal: 10.w,
                                  paddingVertical: 0,
                                  hintText: "Price",
                                  borderSideColor: AppColors.grayColor.withOpacity(0.3),
                                  keyboardType: TextInputType.number,
                                  hintStyle: AppStyles.medium12gray,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text("EG/mo", style: AppStyles.bold10Primary),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20.h),

                      Text("Description:", style: AppStyles.medium16black),
                      SizedBox(height: 5.h),
                      CustomTextFormField(
                        controller: viewModel.descriptionCRl,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        hintText: "Enter Apartment Description",
                        borderSideColor: AppColors.grayColor.withOpacity(0.3),
                      ),
                      SizedBox(height: 20.h),

                      /// Photos Section
                      Text("Property Photos:", style: AppStyles.medium16black),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          if (viewModel.apartmentImages.isNotEmpty)
                            Expanded(
                              child: SizedBox(
                                height: 100.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: viewModel.apartmentImages.length,
                                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () => openFullScreenGallery(context, index, viewModel.apartmentImages),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          viewModel.apartmentImages[index],
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
                                        viewModel.pickImage(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo),
                                      title: const Text("Gallery"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        viewModel.pickImage(ImageSource.gallery);
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
                                    border: Border.all(
                                        color: AppColors.grayColor.withOpacity(0.3)),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.add_a_photo, color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      /// Counters
                      Text("Property Details:", style: AppStyles.medium16black),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          propertyDetailsColumn(
                            name: "Bedrooms",
                            imageName: AppAssets.bedroomsIcon,
                            value: viewModel.bedrooms,
                            onIncrease: () => viewModel.increaseBedrooms(),
                            onDecrease: () => viewModel.decreaseBedrooms(),
                          ),
                          propertyDetailsColumn(
                            name: "Bathrooms",
                            imageName: AppAssets.bathroomsIcon,
                            value: viewModel.bathrooms,
                            onIncrease: () => viewModel.increaseBathrooms(),
                            onDecrease: () => viewModel.decreaseBathrooms(),
                          ),
                          propertyDetailsColumn(
                            name: "Living Rooms",
                            imageName: AppAssets.livingRoomsIcon,
                            value: viewModel.livingRooms,
                            onIncrease: () => viewModel.increaseLivingRooms(),
                            onDecrease: () => viewModel.decreaseLivingRooms(),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      Center(
                        child: CustomElevatedButtom(
                          onPressed: () {
                            viewModel.uploadApartment();
                          },
                          text: "Post Apartment",
                          width: 250.w,
                          backgroundColorElevated: AppColors.primaryColor,
                          textStyle: AppStyles.semiBold20White,
                          borderColor: Colors.transparent,
                          customPadding: 19.h,
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
    );
  }

  void openFullScreenGallery(BuildContext context, int initialIndex, List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: images.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(images[index]),
                    initialScale: PhotoViewComputedScale.contained,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: initialIndex),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget propertyDetailsColumn({
    required String name,
    required String imageName,
    required int value,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Column(
      children: [
        Image.asset(imageName, width: 34.w),
        SizedBox(height: 4.h),
        Text(name, style: AppStyles.medium12gray),
        SizedBox(height: 8.h),
        Row(
          children: [
            InkWell(
              onTap: onDecrease,
              child: CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.offWhiteColor,
                child: Icon(Icons.remove, size: 16.sp, color: Colors.black),
              ),
            ),
            SizedBox(width: 8.w),
            Text(value.toString(), style: AppStyles.bold10black),
            SizedBox(width: 8.w),
            InkWell(
              onTap: onIncrease,
              child: CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.add, size: 16.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
