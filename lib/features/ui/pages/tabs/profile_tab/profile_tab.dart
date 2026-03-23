import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sokon/core/cache/cubit_manger/user_states.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ImagePicker _imagePicker = ImagePicker();
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserViewModel, UserState>(
      builder: (context, state) {
        var userViewModel = context.read<UserViewModel>();
        var user = userViewModel.user;
        bool isOwner = user?.role == 'owner';
        bool isClient = user?.role == 'client';
        String? photoUrl = user?.photoUrl;

        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor, width: 3.w),
                            ),
                            child: CircleAvatar(
                              radius: 70.r,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: profileImage != null
                                  ? FileImage(profileImage!)
                                  : (photoUrl != null && photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : AssetImage(AppAssets.profileImage)) as ImageProvider,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(user?.name ?? "No Name", style: AppStyles.bold20black),
                    SizedBox(height: 5.h),
                    Text(user?.email ?? "No Email", style: AppStyles.regular14black),
                    SizedBox(height: 40.h),
                    Divider(color: AppColors.grayColor.withOpacity(0.3), thickness: 1.h),
                    SizedBox(height: 20.h),
                    buildRowTile(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      color: Colors.blue,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.settingsScreenRoute),
                    ),
                    SizedBox(height: 20.h),
                    buildRowTile(
                      icon: Icons.payment_outlined,
                      title: "Payment",
                      color: Colors.orange,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.addCardRoute),
                    ),
                    if (isClient) ...[
                      SizedBox(height: 20.h),
                      buildRowTile(
                        icon: Icons.bookmark_border_outlined,
                        title: "My Bookings",
                        color: Colors.pink,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.myBookingsRoute);
                        },
                      ),
                    ],
                    if (isOwner) ...[
                      SizedBox(height: 20.h),
                      buildRowTile(
                        icon: Icons.apartment_outlined,
                        title: "My Apartments",
                        color: Colors.green,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.myApartmentsRoute);
                        },
                      ),
                    ],
                    SizedBox(height: 20.h),
                    buildRowTile(
                      icon: Icons.notifications_none_outlined,
                      title: "Notification",
                      color: Colors.purple,
                      onTap: () {},
                    ),
                    SizedBox(height: 20.h),
                    buildRowTile(
                      icon: Icons.info_outline,
                      title: "About",
                      color: Colors.teal,
                      onTap: () {},
                    ),
                    SizedBox(height: 40.h),
                    TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          userViewModel.updateUser(null);
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.loginRoute, (route) => false);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: AppColors.redColor, size: 20.sp),
                            SizedBox(width: 5.w),
                            Text(
                              "Logout",
                              style: AppStyles.medium16RedColor,
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () {
                        AlertDialogUtils.showMessage(
                          context: context,
                          title: "Delete Your Account?",
                          msg: "Once you submit your deletion request, you will receive an email to verify your identity. We will retain required data and delete the rest within 30 days. You will not be able to retrieve your information once this process has completed.",
                          pos: CustomElevatedButtom(
                            onPressed: () => Navigator.pop(context),
                            text: "Confirm Delete",
                            textStyle: AppStyles.semiBold14White,
                            borderRadius: 10,
                            width: 120.w,
                            backgroundColorElevated: AppColors.redColor,
                          ),
                          nav: CustomElevatedButtom(
                            onPressed: () => Navigator.pop(context),
                            borderRadius: 10,
                            text: "Cancel",
                            textStyle: AppStyles.semiBold14White,
                            width: 120.w,
                            backgroundColorElevated: AppColors.grayColor,
                          ),
                        );
                      },
                      child: Text(
                        "Delete account",
                        style: AppStyles.medium16RedColor,
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildRowTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(title, style: AppStyles.semiBold15black),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grayColor, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
