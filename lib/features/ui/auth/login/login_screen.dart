import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import '../widgets/circle_avatar_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController(
    text: "samer99@gmail.com",
  );
  final TextEditingController passwordCtrl = TextEditingController(
    text: "Samer@1234",
  );
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
              SizedBox(height: 50.h),
              Image.asset(AppAssets.SOKON),
              SizedBox(height: 50.h),
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
                        SizedBox(height: 36.h),
                        Center(
                          child: Text("Login", style: AppStyles.bold32Primary),
                        ),
                        SizedBox(height: 48.h),
                        CustomTextFormField(
                          controller: emailCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Username",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          validator: (val) {
                            AppValidators.validateEmail(val);
                            return null;
                          },
                        ),
                        SizedBox(height: 13.h),

                        /// PASSWORD FIELD
                        CustomTextFormField(
                          controller: passwordCtrl,
                          hintStyle: AppStyles.medium12gray,
                          hintText: "Password",
                          fillColor: AppColors.offWhiteColor,
                          borderSideColor: AppColors.grayColor,
                          obscureText: hidePassword,
                          validator: (val) {
                            AppValidators.validatePassword(val);
                            return null;
                          },
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
                        SizedBox(height: 15.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.forgetPasswordRoute);
                            },
                            child: Text(
                              "Forgot password ?",
                              style: AppStyles.semiBold14Primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 27.h),
                        CustomElevatedButtom(
                          onPressed: () {
                            //viewModel.login();
                          },
                          text: "Login",
                          width: 200,
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
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppStyles.regular14gray,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.registerRoute);
                              },
                              child: Text(
                                "Sign Up",
                                style: AppStyles.semiBold14Primary,
                              ),
                            ),
                            SizedBox(height: 50.h),
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
