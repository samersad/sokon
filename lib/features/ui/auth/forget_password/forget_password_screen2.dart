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

class ForgetPasswordScreen2 extends StatefulWidget {
  const ForgetPasswordScreen2({super.key});

  @override
  State<ForgetPasswordScreen2> createState() => _ForgetPasswordScreen2State();
}

class _ForgetPasswordScreen2State extends State<ForgetPasswordScreen2> {

  final TextEditingController passwordCtrl = TextEditingController(
    text: "",
  );  final TextEditingController confirmPasswordCtrl = TextEditingController(
    text: "",
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
                      SizedBox(height: 20.h),
                      CustomTextFormField(
                        controller: passwordCtrl,
                        hintStyle: AppStyles.medium12gray,
                        hintText: "New Password",
                        fillColor: AppColors.offWhiteColor,
                        borderSideColor: AppColors.grayColor,
                        validator: (val) {
                          AppValidators.validatePassword(val);
                        },
                      ),
                      SizedBox(height: 20.h),

                      CustomTextFormField(
                        controller: confirmPasswordCtrl,
                        hintStyle: AppStyles.medium12gray,
                        hintText: "Confirm New Password",
                        fillColor: AppColors.offWhiteColor,
                        borderSideColor: AppColors.grayColor,
                        validator: (val) {
                          AppValidators.validateConfirmPassword(val,passwordCtrl.text);
                        },
                      ),
                      SizedBox(height: 70.h),
                      CustomElevatedButtom(
                        onPressed: () {
                         Navigator.of(context).pushNamed(AppRoutes.verificationRoute);
                        },
                        text: "Finish",
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
