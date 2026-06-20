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

class ForgetPasswordScreen2 extends StatefulWidget {
  const ForgetPasswordScreen2({super.key});

  @override
  State<ForgetPasswordScreen2> createState() => _ForgetPasswordScreen2State();
}

class _ForgetPasswordScreen2State extends State<ForgetPasswordScreen2> {
  final ForgetPasswordViewModel viewModel = getIt<ForgetPasswordViewModel>();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: viewModel,
      child: BlocConsumer<ForgetPasswordViewModel, ForgetPasswordState>(
        listener: (context, state) {
          if (state is ForgetPasswordLoading) {
            AlertDialogUtils.showLoading(context: context, msg: "Updating password...");
          } else if (state is ForgetPasswordError) {
            AlertDialogUtils.hideLoading(context: context);
            AlertDialogUtils.showMessage(context: context, msg: state.message, title: "Error");
          } else if (state is ResetPasswordSuccess) {
            AlertDialogUtils.hideLoading(context: context);
            AlertDialogUtils.showMessage(
              context: context,
              msg: "Password reset successfully. Please login with your new password.",
              title: "Success",
              pos: Text("Login", style: AppStyles.bold12PrimaryColor),
              posAction: () {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
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
                        child: Text("New Password", style: theme.textTheme.headlineMedium),
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
                          SizedBox(height: 20.h),
                          CustomTextFormField(
                            controller: passwordCtrl,
                            hintStyle: theme.textTheme.titleLarge,
                            hintText: "New Password",
                            obscureText: viewModel.hidePassword,
                            suffixIconName: IconButton(
                              icon: Icon(
                                viewModel.hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                viewModel.changePasswordVisibility();
                              },
                            ),
                            fillColor: theme.disabledColor,
                            borderSideColor: theme.highlightColor,
                            validator: (val) => AppValidators.validatePassword(val),
                          ),
                          SizedBox(height: 20.h),
                          CustomTextFormField(
                            controller: confirmPasswordCtrl,
                            hintStyle: theme.textTheme.bodyMedium,
                            hintText: "Confirm New Password",
                            obscureText: viewModel.hidePassword,
                            suffixIconName: IconButton(
                              icon: Icon(
                                viewModel.hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                viewModel.changePasswordVisibility();
                              },
                            ),
                            fillColor: theme.disabledColor,
                            borderSideColor: theme.highlightColor,
                            validator: (val) => AppValidators.validateConfirmPassword(val, passwordCtrl.text),
                          ),
                          SizedBox(height: 70.h),
                          CustomElevatedButtom(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                viewModel.resetPassword(passwordCtrl.text);
                              }
                            },
                            text: "Finish",
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
          );
        },
      ),
    );
  }
}
