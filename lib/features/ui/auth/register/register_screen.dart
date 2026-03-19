import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import '../widgets/circle_avatar_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 120.h),
              Center(child: Text("Sign Up", style: AppStyles.bold32Primary)),
              SizedBox(height: 100.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(67),
                    topLeft: Radius.circular(67),
                  ),
                ),
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 37.w),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 19.h),
                        CustomTextFormField(
                          controller: userCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Username",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          validator: (val) => AppValidators.validateUsername(val),
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          controller: emailCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Email",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          validator: (val) => AppValidators.validateEmail(val),
                        ),
                        SizedBox(height: 16.h),

                        /// PASSWORD FIELD
                        CustomTextFormField(
                          controller: passwordCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Password",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          obscureText: hidePassword,
                          validator: (val) => AppValidators.validatePassword(val),
                          suffixIconName: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => hidePassword = !hidePassword);
                            },
                          ),
                        ),
                        SizedBox(height: 79.h),
                        CustomElevatedButtom(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              AlertDialogUtils.showMessage(
                                context: context,
                                posAction: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.homeScreenRoute,
                                    (route) => false,
                                  );
                                },
                                navAction: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.homeScreenRoute,
                                    (route) => false,
                                  );
                                },
                                msg: "Welcome! Please choose your role:",
                                pos: Container(
                                  width: 100.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Owner",
                                      style: AppStyles.semiBold20White,
                                    ),
                                  ),
                                ),
                                nav: Container(
                                  width: 100.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Client",
                                      style: AppStyles.semiBold20White,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          text: "Sign up",
                          width: 250.w,
                          backgroundColorElevated: AppColors.primaryColor,
                          textStyle: AppStyles.semiBold20White,
                          borderColor: Colors.transparent,
                          customPadding: 19.h,
                        ),
                        SizedBox(height: 30.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          spacing: 10.w,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: CircleAvatarContainer(
                                image: AppAssets.googleIcon,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: CircleAvatarContainer(
                                image: AppAssets.appleIcon,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: CircleAvatarContainer(
                                image: AppAssets.facebookIcon,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "have an account?",
                              style: AppStyles.regular14gray,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.loginRoute);
                              },
                              child: Text(
                                "Login",
                                style: AppStyles.semiBold14Primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
