import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_states.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../../../core/utils/app_routes.dart';
import '../../../../widgets/back_container.dart';

class MyApartmentsScreen extends StatefulWidget {
  const MyApartmentsScreen({super.key});

  @override
  State<MyApartmentsScreen> createState() => _MyApartmentsScreenState();
}

class _MyApartmentsScreenState extends State<MyApartmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserViewModel>().user;
      if (user != null) {
        context.read<ApartmentViewModel>().getAllApartmentForOwner(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ApartmentViewModel, ApartmentState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Row(
                    children: [
                      const BackContainer(),
                      SizedBox(width: 15.w),
                      Text("My Apartments", style: theme.textTheme.headlineLarge),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Manage your properties",
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ApartmentState state) {
    final theme = Theme.of(context);
    if (state is ApartmentLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    } else if (state is ApartmentError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 12.h),
              Text(state.message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    } else if (state is ApartmentLoaded) {
      if (state.apartments.isEmpty) {
        return _buildEmptyState(context);
      }
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: state.apartments.length,
        separatorBuilder: (context, index) => SizedBox(height: 18.h),
        itemBuilder: (context, index) {
          final apartment = state.apartments[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: apartment.images != null && apartment.images!.isNotEmpty
                            ? Image.network(
                                apartment.images![0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(AppAssets.imageC, fit: BoxFit.cover),
                              )
                            : Image.asset(AppAssets.imageC, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(AppAssets.star, width: 14.w),
                              SizedBox(width: 4.w),
                              Text("4.7", style: theme.textTheme.labelMedium),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                apartment.name ?? "No Name",
                                style: theme.textTheme.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "EGP ${apartment.price?.toInt() ?? 0}",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  TextSpan(
                                    text: " /mo",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Image.asset(AppAssets.locationOrange, width: 14.w),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                apartment.address ?? "No Address",
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildFeature(context, AppAssets.bedroomsIcon, "${apartment.bedrooms ?? 0} Beds"),
                            SizedBox(width: 16.w),
                            _buildFeature(context, AppAssets.bathroomsIcon, "${apartment.bathrooms ?? 0} Baths"),
                            SizedBox(width: 16.w),
                            _buildFeature(context, AppAssets.livingRoomsIcon, "${apartment.livingRooms ?? 0} Living"),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editApartmentRoute,
                                    arguments: apartment,
                                  );
                                },
                                icon: Icon(Icons.edit_rounded, size: 18.sp),
                                label: const Text("Edit Listing"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: IconButton(
                                onPressed: () => _showDeleteDialog(apartment.id!),
                                icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22.sp),
                                tooltip: "Delete",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFeature(BuildContext context, String asset, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 16.w, color: theme.primaryColor.withOpacity(0.7)),
        SizedBox(width: 4.w),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.r),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                )
              ],
            ),
            child: Icon(Icons.home_work_outlined, size: 70.sp, color: theme.primaryColor.withOpacity(0.2)),
          ),
          SizedBox(height: 24.h),
          Text("No apartments found", style: theme.textTheme.titleMedium),
          SizedBox(height: 10.h),
          Text("You haven't listed any apartments yet.\nStart by adding your first property!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () {
               Navigator.pushNamed(context, AppRoutes.addApartmentRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
            ),
            child: const Text("Add New Listing"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String apartmentId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10.w),
            Text("Delete Listing", style: theme.textTheme.titleMedium),
          ],
        ),
        content: Text("Are you sure you want to delete this property? This action cannot be undone and the listing will be removed immediately.",
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: theme.textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final user = context.read<UserViewModel>().user;
              if (user != null) {
                context.read<ApartmentViewModel>().deleteApartment(apartmentId, user.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
