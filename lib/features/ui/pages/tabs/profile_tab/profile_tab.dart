import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70.r,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : AssetImage(AppAssets.profileImage)
                                  as ImageProvider,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text("Brooklyn Simmons", style: AppStyles.semiBold15black),
                SizedBox(height: 5.h),
                Text("brooklynsim@gmail.com", style: AppStyles.regular14gray),
                SizedBox(height: 80.h),
                Container(
                  width: double.infinity,
                  height: 2.h,
                  decoration: BoxDecoration(color: AppColors.grayColor),
                ),
                SizedBox(height: 20.h),

                buildRowTile(
                  iconName: AppAssets.settingsIcon,
                  title: "settings",
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.settingsScreenRoute),
                ),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.paymentIcon,
                  title: "Payment",
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.addCardRoute),
                ),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.notificationIcon,
                  title: "Notification",
                  onTap: () => print("settings"),
                ),
                SizedBox(height: 20.h),
                buildRowTile(
                  iconName: AppAssets.aboutIcon,
                  title: "About",
                  onTap: () => print("settings"),
                ),
                SizedBox(height: 60.h),

                TextButton(
                  onPressed: () {
                    AlertDialogUtils.showMessage(
                      context: context,
                      title: "Delete Your Account?",

                      msg:
                          "Once you submit your deletion request, you will receive an email to verify your identity. we willrequired to retain will be deleted within 30 days.You will not beable to retrieve your information once thisprocess has completed.",
                      pos: CustomElevatedButtom(onPressed: (){Navigator.pop(context);},
                          text: "Confirm Delete",textStyle: AppStyles.semiBold14White,
                          borderRadius: 10,
                          width: 110.w),
                      nav: CustomElevatedButtom(onPressed: (){Navigator.pop(context);},
                          borderRadius: 10,
                          text: "Cancel",textStyle: AppStyles.semiBold14White,
                          width: 110.w),
                    );
                  },
                  child: Text(
                    "Delete account",
                    style: AppStyles.medium16RedColor,
                  ),
                ),
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
    return Row(
      children: [
        Image.asset(iconName, scale: 0.8),
        SizedBox(width: 10.w),
        Text(title, style: AppStyles.semiBold15black),
        Spacer(),
        IconButton(
          onPressed: () => onTap(),
          icon: Icon(Icons.arrow_forward_ios, color: AppColors.grayColor),
        ),
      ],
    );
  }
}
