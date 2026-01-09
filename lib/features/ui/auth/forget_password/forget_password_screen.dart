import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {

  final TextEditingController emailCtrl = TextEditingController(
    text: "samersaa99@gmail.com",
  );
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return
     Scaffold(
        backgroundColor: AppColors.whiteColor,

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Image.asset(AppAssets.forgetBg)  ,
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 70.h,horizontal: 15.w),
                    child: Text("Forgot Password",style: AppStyles.regular30primary,),
                  ),

                ],
              ),
              SizedBox(height: 25.h),
              Form(
                key: formkey,
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Enter Your Email Address ",style: AppStyles.regular15black,),
                      SizedBox(height: 20.h),
                      CustomTextFormField(
                        controller: emailCtrl,
                        hintStyle: AppStyles.medium12gray,
                        hintText: "Password",
                        fillColor: AppColors.offWhiteColor,
                        borderSideColor: AppColors.grayColor,
                        validator: (val) {
                          AppValidators.validateEmail(val);
                        },
                      ),
                      SizedBox(height: 40.h),
                      CustomElevatedButtom(
                        onPressed: () {
                         Navigator.of(context).pushNamed(AppRoutes.verificationRoute);
                        },
                        text: "Continue",
                        width: 336.w,
                      borderRadius: 30.r,
                        backgroundColorElevated: AppColors.primaryColor,
                        textStyle: AppStyles.semiBold20White,
                        borderColor: AppColors.blackColor,
                        customPadding: 16.h,
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

}
