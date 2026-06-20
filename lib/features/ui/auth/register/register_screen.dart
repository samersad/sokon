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
import 'cubit/register_states.dart';
import 'cubit/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel viewModel = getIt<RegisterViewModel>();

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);
    return BlocListener<RegisterViewModel, RegisterStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is RegisterLoadingStates) {
          AlertDialogUtils.showLoading(context: context, msg: 'Loading...');
        } else if (state is RegisterErrorStates) {
          AlertDialogUtils.hideLoading(context: context);
          AlertDialogUtils.showMessage(
            context: context,
            msg: state.errorMessage,
            pos: Text("Ok", style: theme.textTheme.labelMedium),
          );
        } else if (state is RegisterNeedsRoleStates) {
          AlertDialogUtils.hideLoading(context: context);
          viewModel.showRoleSelectionDialog(context, state.user, userViewModel);
        } else if (state is RegisterSuccessStates) {
          AlertDialogUtils.hideLoading(context: context);
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeScreenRoute,
            (route) => false,
          );
        }
      },
      child: BlocBuilder<RegisterViewModel, RegisterStates>(
        bloc: viewModel,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 120.h),
                    Center(child: Text("Sign Up", style: theme.textTheme.headlineLarge)),
                    SizedBox(height: 100.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
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
                              SizedBox(height: 19.h),
                              CustomTextFormField(
                                controller: viewModel.userCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: "Username",
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                validator: (val) =>
                                    AppValidators.validateUsername(val),
                              ),
                              SizedBox(height: 16.h),
                              CustomTextFormField(
                                controller: viewModel.emailCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: "Email",
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                validator: (val) =>
                                    AppValidators.validateEmail(val),
                              ),
                              SizedBox(height: 16.h),

                              /// PASSWORD FIELD
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
                              SizedBox(height: 79.h),
                              CustomElevatedButtom(
                                onPressed: () {
                                  viewModel.register(userViewModel);
                                },
                                text: "Sign up",
                                width: 250.w,
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
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "have an account?",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(AppRoutes.loginRoute);
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
        },
      ),
    );
  }
}
