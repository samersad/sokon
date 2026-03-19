import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
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
    var userProvider = Provider.of<UserProvider>(context);
    bool isOwner = userProvider.user?.role == 'owner';

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
                  child: CircleAvatar(
                    radius: 70.r,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : AssetImage(AppAssets.profileImage) as ImageProvider,
                  ),
                ),
                SizedBox(height: 15.h),
                Text(userProvider.user?.name ?? "No Name", style: AppStyles.semiBold15black),
                SizedBox(height: 5.h),
                Text(userProvider.user?.email ?? "No Email", style: AppStyles.regular14gray),
                SizedBox(height: 40.h),
                Divider(color: AppColors.grayColor, thickness: 1.h),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.settingsIcon,
                  title: "Settings",
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settingsScreenRoute),
                ),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.paymentIcon,
                  title: "Payment",
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.addCardRoute),
                ),
                if (isOwner) ...[
                  SizedBox(height: 20.h),
                  buildRowTile(
                    iconName: AppAssets.avatar,
                    title: "My Apartments",
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.myApartmentsRoute);
                    },
                  ),
                ],
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.notificationIcon,
                  title: "Notification",
                  onTap: () {},
                ),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.aboutIcon,
                  title: "About",
                  onTap: () {},
                ),
                SizedBox(height: 40.h),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    userProvider.updateUser(null);
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
  }

  Widget buildRowTile({
    required String iconName,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          children: [
            Image.asset(iconName, width: 24.w, height: 24.w, fit: BoxFit.contain),
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
