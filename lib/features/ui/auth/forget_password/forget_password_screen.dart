import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/features/ui/auth/forget_password/cubit/forget_password_states.dart';
import 'package:sokon/features/ui/auth/forget_password/cubit/forget_password_view_model.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final ForgetPasswordViewModel viewModel = getIt<ForgetPasswordViewModel>();
  final TextEditingController emailCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => viewModel,
      child: BlocListener<ForgetPasswordViewModel, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordLoading) {
            AlertDialogUtils.showLoading(context: context, msg: "Sending OTP...");
          } else if (state is ForgetPasswordError) {
            AlertDialogUtils.hideLoading(context: context);
            AlertDialogUtils.showMessage(context: context, msg: state.message, title: "Error");
          } else if (state is ForgetPasswordSuccess) {
            AlertDialogUtils.hideLoading(context: context);
            Navigator.of(context).pushNamed(AppRoutes.verificationRoute, arguments: emailCtrl.text);
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Image.asset(AppAssets.forgetBg),
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 70.h, horizontal: 15.w),
                      child: Text("Forgot Password", style: theme.textTheme.headlineMedium),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Enter Your Email Address ", style: theme.textTheme.bodyMedium),
                        SizedBox(height: 20.h),
                        CustomTextFormField(
                          controller: emailCtrl,
                          hintStyle: theme.textTheme.bodyMedium,
                          hintText: "Email",
                          fillColor: theme.disabledColor,
                          borderSideColor: theme.highlightColor,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Email is required";
                            return AppValidators.validateEmail(val);
                          },
                        ),
                        SizedBox(height: 40.h),
                        CustomElevatedButtom(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              viewModel.sendOTP(emailCtrl.text);
                            }
                          },
                          text: "Continue",
                          width: 336.w,
                          borderRadius: 30.r,
                          backgroundColorElevated: theme.primaryColor,
                          textStyle: AppStyles.semiBold20White,
                          borderColor: Colors.transparent,
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
        ),
      ),
    );
  }
}
