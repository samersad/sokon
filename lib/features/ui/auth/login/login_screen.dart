import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/app_validator.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import '../widgets/circle_avatar_container.dart';
import 'cubit/login_states.dart';
import 'cubit/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel viewModel = getIt<LoginViewModel>();

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);
    return BlocListener<LoginViewModel, LoginStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is LoginLoadingStates) {
          AlertDialogUtils.showLoading(context: context, msg: 'Loading...');
        } else if (state is LoginErrorStates) {
          AlertDialogUtils.hideLoading(context: context);
          AlertDialogUtils.showMessage(
            context: context,
            msg: state.message,
            pos: Text("Ok", style: theme.textTheme.labelMedium),
          );
        } else if (state is LoginSuccessStates) {
          AlertDialogUtils.hideLoading(context: context);
          Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreenRoute);
        } else if (state is LoginNeedsRoleStates) {
          AlertDialogUtils.hideLoading(context: context);
          viewModel.showRoleSelectionDialog(context, state.user, userViewModel);
        }
      },
      child: BlocBuilder<LoginViewModel, LoginStates>(
        bloc: viewModel,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 50.h),
                    Center(
                      child: Image.asset(
                        AppAssets.brandLogo,
                        width: 220.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.offWhiteColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(67),
                          topLeft: Radius.circular(67),
                        ),
                      ),
                      child: Form(
                        key: viewModel.formKey,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 37.w),
                          child: Column(
                            children: [
                              SizedBox(height: 36.h),
                              Center(
                                child: Text("Login", style: theme.textTheme.headlineLarge),
                              ),
                              SizedBox(height: 48.h),
                              CustomTextFormField(
                                controller: viewModel.emailCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: "Email",
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                validator: (val) =>
                                    AppValidators.validateEmail(val),
                              ),
                              SizedBox(height: 13.h),
                              CustomTextFormField(
                                controller: viewModel.passwordCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: "Password",
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                obscureText: viewModel.hidePassword,
                                validator: (val) =>
                                    AppValidators.validatePassword(val),
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
                              ),
                              SizedBox(height: 15.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        AppRoutes.forgetPasswordRoute);
                                  },
                                child: Text(
                                  "Forgot password ?",
                                  style: theme.textTheme.displaySmall,
                                ),
                              ),
                              ),
                              SizedBox(height: 27.h),
                              CustomElevatedButtom(
                                onPressed: () {
                                  viewModel.login(userViewModel);
                                },
                                text: "Login",
                                width: 200,
                                backgroundColorElevated: theme.primaryColor,
                                textStyle: theme.textTheme.titleLarge,
                                borderColor: Colors.transparent,
                                customPadding: 19.h,
                              ),
                              SizedBox(height: 30.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      viewModel.signInWithGoogle(userViewModel);
                                    },
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
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacementNamed(
                                          AppRoutes.registerRoute);
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
        },
      ),
    );
  }
}
