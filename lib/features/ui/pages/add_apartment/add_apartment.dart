import 'dart:io';
import 'package:sokon/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sokon/core/cache/cubit_manger/location_states.dart';
import 'package:sokon/core/cache/cubit_manger/location_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_states.dart';
import 'package:sokon/features/ui/pages/add_apartment/cubit/add_apartment_view_model.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';
import 'package:sokon/features/ui/widgets/app_video_player.dart';
import 'package:sokon/features/ui/widgets/custom_text_form_field.dart';
import 'package:sokon/features/ui/widgets/labeled_info_field.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final userViewModel = context.read<UserViewModel>();

    return BlocListener<AddApartmentViewModel, AddApartmentStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is AddApartmentLoading) {
          _isLoadingDialogShowing = true;
          AlertDialogUtils.showLoading(context: context, msg: l10n.uploading);
        } else if (state is AddApartmentProgress) {
          AlertDialogUtils.hideLoading(context: context);
          AlertDialogUtils.showLoading(context: context, msg: state.message);
        } else if (state is AddApartmentError) {
          if (_isLoadingDialogShowing) {
            _isLoadingDialogShowing = false;
            AlertDialogUtils.hideLoading(context: context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.redColor,
            ),
          );
        } else if (state is AddApartmentSuccess) {
          if (_isLoadingDialogShowing) {
            _isLoadingDialogShowing = false;
            AlertDialogUtils.hideLoading(context: context);
          }
          AlertDialogUtils.showMessage(
            context: context,
            msg: l10n.apartmentAddedSuccess,
            title: l10n.success,
            pos: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("OK", style: AppStyles.bold14Primary),
                  SizedBox(width: 5.w),
                  Icon(Icons.check, color: AppColors.primaryColor, size: 20.sp),
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final screenColor =
              isDark
                  ? AppColors.addApartmentDarkBackground
                  : AppColors.addApartmentLightBackground;
          final accentColor = _accentColor(context);

          return Scaffold(
            backgroundColor: screenColor,
            appBar: AppBar(
              backgroundColor: screenColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.appBarTheme.foregroundColor ??
                      (isDark ? AppColors.whiteColor : AppColors.blackColor),
                ),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                l10n.addApartment,
                style: (theme.textTheme.headlineMedium ??
                        AppStyles.medium16black)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaSection(),
                  SizedBox(height: 24.h),
                  _buildBasicInfoSection(),
                  SizedBox(height: 24.h),
                  _buildPropertyDetailsSection(),
                  SizedBox(height: 24.h),
                  _buildLocationSection(locationViewModel),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                decoration: BoxDecoration(
                  color: screenColor,
                  border: Border(
                    top: BorderSide(
                      color: _borderColor(context).withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 56.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.uploadApartment(userViewModel, locationViewModel);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      shadowColor: AppColors.primaryColor.withValues(alpha: 0.3),
                      backgroundColor: accentColor,
                      foregroundColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                    ),
                    child: Text(
                      l10n.addApartment,
                      style: AppStyles.semiBold14White.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Color _accentColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.displaySmall?.color ?? theme.primaryColor;
  }

  Widget _buildMediaSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MediaPickerCard(
                icon: Icons.add_a_photo_outlined,
                label: viewModel.apartmentImages.isEmpty
                    ? l10n.addPhotos
                    : "${viewModel.apartmentImages.length} Photo${viewModel.apartmentImages.length == 1 ? '' : 's'}",
                onTap: _showPhotoSourceSheet,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MediaPickerCard(
                icon: Icons.video_call_outlined,
                label: viewModel.videoFile == null ? l10n.addVideo : l10n.videoAdded,
                onTap: _showVideoSourceSheet,
              ),
            ),
          ],
        ),
        if (viewModel.apartmentImages.isNotEmpty ||
            viewModel.videoFile != null) ...[
          SizedBox(height: 14.h),
          _buildMediaPreviewSection(),
        ],
      ],
    );
  }

  Widget _buildMediaPreviewSection() {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.selectedMedia,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.apartmentImages.isNotEmpty) ...[
            SizedBox(
              height: 104.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.apartmentImages.length,
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  return _PhotoPreviewTile(
                    image: viewModel.apartmentImages[index],
                    onTap: () => openFullScreenGallery(
                      context,
                      index,
                      viewModel.apartmentImages,
                    ),
                    onRemove: () => viewModel.removeNewImage(index),
                  );
                },
              ),
            ),
          ],
          if (viewModel.apartmentImages.isNotEmpty &&
              viewModel.videoFile != null)
            SizedBox(height: 16.h),
          if (viewModel.videoFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  AppVideoPlayer.file(
                    viewModel.videoFile!.path,
                    key: ValueKey(viewModel.videoFile!.path),
                    height: 190.h,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _RemoveMediaButton(
                      onTap: () {
                        setState(() {
                          viewModel.videoFile = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.basicInformation,
      child: Column(
        children: [
          LabeledInfoField(
            label: l10n.apartmentNameLabel,
            explanation: l10n.apartmentNameHint,
            child: _designField(
              controller: viewModel.nameCRl,
              hintText: l10n.apartmentNameHintText,
            ),
          ),
          SizedBox(height: 18.h),
          LabeledInfoField(
            label: l10n.monthlyPriceLabel,
            explanation: l10n.monthlyPriceHint,
            child: _designField(
              controller: viewModel.priceCRl,
              hintText: l10n.zeroPriceHint,
              keyboardType: TextInputType.number,
              suffixIconName: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    l10n.egp,
                    style: (Theme.of(context).textTheme.displaySmall ??
                            AppStyles.bold14Primary)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          LabeledInfoField(
            label: l10n.description,
            explanation: l10n.propertyDetailsHint,
            child: _designField(
              controller: viewModel.descriptionCRl,
              hintText: l10n.propertyDetailsPlaceholder,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              paddingVertical: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsSection() {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.propertyDetails,
      child: Column(
        children: [
          _StepperRow(
            icon: Icons.bed_outlined,
            label: l10n.bedrooms,
            explanation: "Select the total number of private/shared bedrooms in this apartment.",
            value: viewModel.bedrooms,
            onIncrease: viewModel.increaseBedrooms,
            onDecrease: viewModel.decreaseBedrooms,
          ),
          _StepperRow(
            icon: Icons.bathtub_outlined,
            label: l10n.bathrooms,
            explanation: l10n.selectBathrooms,
            value: viewModel.bathrooms,
            onIncrease: viewModel.increaseBathrooms,
            onDecrease: viewModel.decreaseBathrooms,
          ),
          _StepperRow(
            icon: Icons.chair_outlined,
            label: l10n.livingRooms,
            explanation: "Select the number of common/living areas.",
            value: viewModel.livingRooms,
            onIncrease: viewModel.increaseLivingRooms,
            onDecrease: viewModel.decreaseLivingRooms,
          ),
          _StepperRow(
            icon: Icons.groups_outlined,
            label: l10n.livingCapacity,
            explanation: l10n.selectLivingCapacity,
            value: viewModel.maxPeople,
            onIncrease: viewModel.increaseMaxPeople,
            onDecrease: viewModel.decreaseMaxPeople,
          ),
          _StepperRow(
            icon: Icons.stairs_outlined,
            label: l10n.floor(""),
            explanation: l10n.selectFloor,
            value: viewModel.floor,
            onIncrease: () => _setFloor(viewModel.floor + 1),
            onDecrease: () {
              if (viewModel.floor > 1) {
                _setFloor(viewModel.floor - 1);
              }
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(LocationViewModel locationViewModel) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.locationDetails,
      child: BlocBuilder<LocationViewModel, LocationState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledInfoField(
                label: l10n.address,
                explanation: l10n.streetAddressHint,
                child: _designField(
                  controller: viewModel.addressCRl,
                  hintText: l10n.streetAddressLabel,
                  suffixIconName: Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.locationPickerRoute,
                      ),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: _accentColor(context),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: AppColors.whiteColor,
                          size: 21.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if ((locationViewModel.apartmentAddress ?? '').isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  "Selected on map: ${locationViewModel.apartmentAddress}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.regular12gray.copyWith(
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: LabeledInfoField(
                      label: l10n.city,
                      explanation: l10n.selectCity,
                      child: _designField(
                        controller: viewModel.cityCRl,
                        readOnly: true,
                        hintText: l10n.assiutHint,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: LabeledInfoField(
                      label: l10n.district,
                      explanation: l10n.selectDistrict,
                      child: _designField(
                        controller: viewModel.districtCRl,
                        readOnly: true,
                        onTap: () => _showDistrictPicker(context),
                        hintText: "e.g. city",
                        suffixIconName: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).highlightColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  CustomTextFormField _designField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? suffixIconName,
    bool readOnly = false,
    VoidCallback? onTap,
    double paddingVertical = 17,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      hintStyle: (theme.textTheme.bodyMedium ?? AppStyles.regular14gray)
          .copyWith(
        color: theme.highlightColor.withValues(alpha: isDark ? 0.55 : 0.75),
        fontSize: 16.sp,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      suffixIconName: suffixIconName,
      readOnly: readOnly,
      onTap: onTap,
      fillColor: isDark ? theme.disabledColor : AppColors.addApartmentLightField,
      borderSideColor: AppColors.transparentColor,
      borderRadius: 10,
      paddingHorizontal: 16,
      paddingVertical: paddingVertical,
    );
  }

  void _setFloor(int value) {
    viewModel.floorCRl.text = value.toString();
    viewModel.setFloor(value.toString());
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(ImageSource.gallery);
                },
              ),
              if (viewModel.apartmentImages.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.image_search_outlined),
                  title: Text(l10n.previewSelectedPhotos),
                  onTap: () {
                    Navigator.pop(context);
                    openFullScreenGallery(context, 0, viewModel.apartmentImages);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDistrictPicker(BuildContext context) async {
    final selectedDistrict = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Select District",
                  style: AppStyles.medium16black.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                ...AddApartmentViewModel.districtOptions.map(
                  (district) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(district),
                    trailing: viewModel.districtCRl.text.trim() == district.trim()
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 22.sp,
                          )
                        : null,
                    onTap: () => Navigator.pop(sheetContext, district),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDistrict != null) {
      viewModel.setDistrict(selectedDistrict);
    }
  }

  void openFullScreenGallery(
    BuildContext context,
    int initialIndex,
    List<File> images,
  ) {
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
                backgroundDecoration:
                    const BoxDecoration(color: AppColors.blackColor),
                pageController: PageController(initialPage: initialIndex),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.whiteColor,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _borderColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? AppColors.addApartmentDarkBorder
      : AppColors.addApartmentLightBorder;
}

class _MediaPickerCard extends StatelessWidget {
  const _MediaPickerCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _AddApartmentState._accentColor(context);

    return InkWell(
      borderRadius: BorderRadius.circular(22.r),
      onTap: onTap,
      child: Container(
        height: 130.h,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: _borderColor(context),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.addApartmentIconDarkFill
                    : AppColors.addApartmentIconLightFill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 24.sp),
            ),
            SizedBox(height: 13.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.medium16primary.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreviewTile extends StatelessWidget {
  const _PhotoPreviewTile({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final File image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.file(
              image,
              width: 104.w,
              height: 104.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 7.h,
          right: 7.w,
          child: _RemoveMediaButton(onTap: onRemove),
        ),
      ],
    );
  }
}

class _RemoveMediaButton extends StatelessWidget {
  const _RemoveMediaButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: AppColors.addApartmentOverlay,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, color: AppColors.whiteColor, size: 16.sp),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (theme.textTheme.labelLarge ?? AppStyles.bold18PrimaryColor)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 18.h),
          child,
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onIncrease,
    required this.onDecrease,
    this.explanation,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final int value;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final String? explanation;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = _AddApartmentState._accentColor(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.highlightColor,
            size: 23.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (theme.textTheme.bodyMedium ?? AppStyles.regular15black)
                        .copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                if (explanation != null && explanation!.isNotEmpty) ...[
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => _showExplanationDialog(context),
                    child: Icon(
                      Icons.info_outline,
                      color: isDark ? AppColors.whiteColor.withOpacity(0.6) : AppColors.primaryColor,
                      size: 16.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 114.w,
            height: 42.h,
            decoration: BoxDecoration(
              color:
                  isDark ? theme.disabledColor : AppColors.addApartmentLightField,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color:
                    isDark
                        ? theme.highlightColor
                        : AppColors.addApartmentSoftBorder,
              ),
            ),
            child: Row(
              children: [
                _StepperButton(icon: Icons.remove, onTap: onDecrease),
                Expanded(
                  child: Text(
                    "$value",
                    textAlign: TextAlign.center,
                    style: AppStyles.medium16primary.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _StepperButton(icon: Icons.add, onTap: onIncrease),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExplanationDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: theme.cardColor,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: (theme.textTheme.titleMedium ?? AppStyles.medium16black)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            explanation!,
            style: (theme.textTheme.bodyMedium ?? AppStyles.regular14gray).copyWith(
              color: theme.highlightColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Got it",
                style: AppStyles.bold14Primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: SizedBox(
        width: 36.w,
        height: 42.h,
        child: Icon(
          icon,
          color: _AddApartmentState._accentColor(context),
          size: 18.sp,
        ),
      ),
    );
  }
}
