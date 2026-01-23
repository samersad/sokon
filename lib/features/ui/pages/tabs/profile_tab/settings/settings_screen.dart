import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';

import '../../../../../../core/utils/app_assets.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../widgets/custom_text_form_field.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text("Edit Profile", style: AppStyles.bold20black),
        centerTitle: true,
      ),
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => pickImage(ImageSource.gallery),
                          child: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.transparentColor,
                            child: Image.asset(
                              AppAssets.cameraIconProfle,scale: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.h),
                Text("Username",style: AppStyles.semiBold14DarkPrimary,),
                SizedBox(height: 5.h),
                CustomTextFormField(
                  hintText: "Username",
                  controller: TextEditingController(text: "Brooklynsim"),
                  paddingVertical: 15.h,
                  borderSideColor: AppColors.grayColor,
                  hintStyle: AppStyles.regular14black,
                  fillColor: AppColors.transparentColor,
                ),
                SizedBox(height:20.h),
                Text("Email",style: AppStyles.semiBold14DarkPrimary,),
                SizedBox(height: 5.h),
                CustomTextFormField(
                  hintText: "Email",
                  controller: TextEditingController(text: "brooklynsim@gmail.com"),
                  paddingVertical: 15.h,
                  borderSideColor: AppColors.grayColor,
                  hintStyle: AppStyles.regular14black,

                  fillColor: AppColors.transparentColor,
                ),
                SizedBox(height:20.h),
                Text("Date of birth",style: AppStyles.semiBold14DarkPrimary,),
                SizedBox(height: 5.h),
                CustomTextFormField(
                  hintText: "Date of birth",
                  controller: TextEditingController(text: "November/21/1992"),
                  paddingVertical: 15.h,
                  borderSideColor: AppColors.grayColor,
                  hintStyle: AppStyles.regular14black,
                  fillColor: AppColors.transparentColor,
                  suffixIconName:  Image.asset(AppAssets.calendarIcon),
                ),
                SizedBox(height: 70.h),
                CustomElevatedButtom(onPressed: () {
                  //todo save change
                },
                  text: "Save Change",
                  width: 500,
                  borderRadius: 10,
                  backgroundColorElevated: AppColors.darkBlueColor,
                  textStyle: AppStyles.semiBold20White,
                )




              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildRowTile({required String iconName,required String title,required VoidCallback onTap}) {
    return  Row(
      children: [
        Image.asset(iconName,scale: 0.8,),
        SizedBox(width: 10.w),
        Text(title,style: AppStyles.semiBold15black, ),
        Spacer(),
        IconButton(onPressed: () => onTap,
            icon: Icon(Icons.arrow_forward_ios,color: AppColors.grayColor,))
      ],
    );

  }

  Future<void> pickImage(ImageSource source) async {
    await _requestPermission(source);
    final XFile? pickedFile =
    await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
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
}
