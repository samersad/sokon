import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_states.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_view_model.dart';
import 'package:sokon/features/ui/widgets/app_video_player.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<LocationViewModel>().clearApartmentLocation();
       viewModel.clearData();
    });
  }


  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);
    return BlocListener<AddApartmentViewModel, AddApartmentStates>(
      bloc: viewModel,
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
        bloc: viewModel,
        builder: (context, state) {
          final locationViewModel = context.read<LocationViewModel>();
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
                    /// Video Section
                    _buildVideoPickerSection(),
                    SizedBox(height: 20.h),

                    Text("Apartment Name:", style: theme.textTheme.labelMedium),
                    SizedBox(height: 5.h),
                    CustomTextFormField(
                      controller: viewModel.nameCRl,
                      hintText: "Enter Apartment Name",
                      borderSideColor: AppColors.grayColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 20.h),

                    Text("Address (optional)", style: theme.textTheme.labelMedium),
                    SizedBox(height: 5.h),
                    BlocBuilder<LocationViewModel, LocationState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: viewModel.addressCRl,
                                    hintText: "Type an address",
                                    borderSideColor: AppColors.grayColor.withOpacity(0.3),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.locationPickerRoute),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.map_outlined, color: AppColors.primaryColor, size: 22.sp),
                                        SizedBox(height: 4.h),
                                        Text("Map", style: AppStyles.bold12Primary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if ((locationViewModel.apartmentAddress ?? '').isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Text(
                                "Selected on map: ${locationViewModel.apartmentAddress}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
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
                        Text("EG/mo", style: theme.textTheme.displaySmall),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Text("Description:", style: theme.textTheme.labelMedium),
                    SizedBox(height: 5.h),
                    CustomTextFormField(
                      controller: viewModel.descriptionCRl,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      hintText: "Enter Apartment Description",
                      borderSideColor: AppColors.grayColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 20.h),

                    Text("Property Photos:", style: theme.textTheme.labelMedium),
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

                    Text("Property Details:", style: theme.textTheme.labelMedium),
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
                    SizedBox(height: 20.h),
                    _buildPeopleCapacityCard(theme),
                    SizedBox(height: 40.h),

                    Center(
                      child: CustomElevatedButtom(
                        onPressed: () {
                          viewModel.uploadApartment(userViewModel, locationViewModel);
                        },
                        text: "Add Apartment",
                        width: 500.w,
                        backgroundColorElevated: AppColors.primaryColor,
                        textStyle: AppStyles.semiBold20White,
                        borderColor: Colors.transparent,
                        customPadding: 19.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPickerSection() {
    final localVideoPath = viewModel.videoFile?.path;
    final remoteVideoUrl =
        localVideoPath == null ? viewModel.existingVideoUrl : null;

    Widget content;
    if (localVideoPath != null) {
      content = AppVideoPlayer.file(
        localVideoPath,
        height: 220.h,
        borderRadius: BorderRadius.circular(24.r),
      );
    } else if (remoteVideoUrl != null && remoteVideoUrl.isNotEmpty) {
      content = AppVideoPlayer.network(
        remoteVideoUrl,
        height: 220.h,
        borderRadius: BorderRadius.circular(24.r),
      );
    } else {
      content = Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.ondemand_video_outlined,
                  size: 40.sp,
                  color: AppColors.darkGrayColor,
                ),
                SizedBox(height: 10.h),
                Text(
                  "Add an apartment video preview",
                  style: AppStyles.medium16black,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => viewModel.pickVideo(ImageSource.camera),
                icon: const Icon(Icons.videocam),
                label: const Text("Camera"),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => viewModel.pickVideo(ImageSource.gallery),
                icon: const Icon(Icons.video_library),
                label: const Text("Gallery"),
              ),
            ),
          ],
        ),
      ],
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
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(imageName, width: 34.w),
        SizedBox(height: 4.h),
        Text(name, style: theme.textTheme.bodyMedium),
        SizedBox(height: 8.h),
        Row(
          children: [
            InkWell(
              onTap: onDecrease,
              child: CircleAvatar(
                radius: 12.r,
                backgroundColor: theme.disabledColor,
                child: Icon(Icons.remove, size: 16.sp, color: theme.highlightColor),
              ),
            ),
            SizedBox(width: 8.w),
            Text(value.toString(), style: theme.textTheme.labelMedium),
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

  Widget _buildPeopleCapacityCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: theme.primaryColor.withOpacity(isDark ? 0.35 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.groups_rounded, color: theme.primaryColor, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Living Capacity", style: theme.textTheme.labelMedium),
                SizedBox(height: 4.h),
                Text(
                  "How many people can live in this apartment?",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _buildCounterChip(
            theme: theme,
            value: viewModel.maxPeople,
            onIncrease: viewModel.increaseMaxPeople,
            onDecrease: viewModel.decreaseMaxPeople,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterChip({
    required ThemeData theme,
    required int value,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrease,
            child: Icon(Icons.remove_circle_outline, color: theme.highlightColor, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Text("$value", style: theme.textTheme.labelMedium),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onIncrease,
            child: Icon(Icons.add_circle, color: theme.primaryColor, size: 22.sp),
          ),
        ],
      ),
    );
  }
}
