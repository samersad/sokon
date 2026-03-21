import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sokon/cloudinary_service.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:sokon/firebase_utils.dart';

import '../../../../../../core/cache/provider/user_provider.dart';
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
  late TextEditingController nameController;
  late TextEditingController emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text("Edit Profile", style: AppStyles.bold20black),
        centerTitle: true,
      ),
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: profileImage != null 
                                ? FileImage(profileImage!)
                                : (userProvider.user?.photoUrl != null && userProvider.user!.photoUrl!.isNotEmpty
                                    ? NetworkImage(userProvider.user!.photoUrl!)
                                    : AssetImage(AppAssets.avatar)) as ImageProvider,
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                pickImage(ImageSource.gallery);
                              },
                              
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
                      controller: nameController,
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
                      controller: emailController,
                      paddingVertical: 15.h,
                      borderSideColor: AppColors.grayColor,
                      hintStyle: AppStyles.regular14black,
                      fillColor: AppColors.transparentColor,
                    ),
                    SizedBox(height: 70.h),
                    CustomElevatedButtom(
                      onPressed: () async {
                        if (userProvider.user == null) return;
                        
                        setState(() => isLoading = true);
                        
                        try {
                          String? photoUrl = userProvider.user?.photoUrl;
                          if (profileImage != null) {
                            photoUrl = await CloudinaryService.uploadImage(profileImage!);
                          }

                          userProvider.user!.name = nameController.text;
                          userProvider.user!.photoUrl = photoUrl;

                          await FireBaseUtils.addUserToFirestore(userProvider.user!);
                          userProvider.updateUser(userProvider.user);
                          
                         Navigator.pop(context);
                        } catch (e) {
                           debugPrint("Error saving changes: $e");
                        } finally {
                         setState(() => isLoading = false);
                        }
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
            if (isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
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
