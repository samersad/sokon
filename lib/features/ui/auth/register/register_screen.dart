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
import '../../../../l10n/app_localizations.dart';
import '../../widgets/alert_dialog_utils.dart';
import '../../widgets/custom_elevated_buttom.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/language_toggle.dart';
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
  void dispose() {
    viewModel.userCtrl.dispose();
    viewModel.emailCtrl.dispose();
    viewModel.collegeCtrl.dispose();
    viewModel.phoneCtrl.dispose();
    viewModel.passwordCtrl.dispose();
    viewModel.confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<RegisterViewModel, RegisterStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is RegisterLoadingStates) {
          AlertDialogUtils.showLoading(context: context, msg: l10n.loading);
        } else if (state is RegisterErrorStates) {
          AlertDialogUtils.hideLoading(context: context);
          AlertDialogUtils.showMessage(
            context: context,
            msg: state.errorMessage,
            pos: Text(l10n.ok, style: theme.textTheme.labelMedium),
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
                    Center(child: Text(l10n.signUp, style: theme.textTheme.headlineLarge)),
                    SizedBox(height: 100.h),
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

                              SizedBox(height: 24.h),
                              CustomTextFormField(
                                controller: viewModel.userCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: l10n.username,
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                validator: (val) =>
                                    AppValidators.validateUsername(val, l10n),
                              ),
                              SizedBox(height: 16.h),
                              CustomTextFormField(
                                controller: viewModel.emailCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: l10n.email,
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                validator: (val) =>
                                    AppValidators.validateEmail(val, l10n),
                              ),
                              SizedBox(height: 16.h),
                              DropdownButtonFormField<String>(
                                value: viewModel.selectedRole,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 15.h,
                                  ),
                                  filled: true,
                                  fillColor: theme.disabledColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: theme.highlightColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                iconEnabledColor: theme.highlightColor,
                                dropdownColor: theme.cardColor,
                                style: theme.textTheme.bodyMedium,
                                hint: Text(l10n.role),
                                items: RegisterViewModel.roleOptions
                                    .map(
                                      (role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(
                                          role == 'owner' ? l10n.owner : l10n.client,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: viewModel.setRole,
                                validator: (value) => value == null || value.isEmpty
                                    ? l10n.fieldRequired
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                              if (!viewModel.isOwner) ...[
                                CustomTextFormField(
                                  controller: viewModel.collegeCtrl,
                                  hintStyle: theme.textTheme.bodyMedium,
                                  hintText: l10n.college,
                                  fillColor: theme.disabledColor,
                                  borderSideColor: theme.highlightColor,
                                  validator: (val) => AppValidators.validateFullName(val, l10n),
                                ),
                                SizedBox(height: 16.h),
                              ],
                              CustomTextFormField(
                                controller: viewModel.phoneCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: l10n.phoneNumber,
                                keyboardType: TextInputType.phone,
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                prefixIconName: Container(
                                  width: 80.w,
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Row(
                                    children: [
                                      Text("🇪🇬", style: TextStyle(fontSize: 20.sp)),
                                      SizedBox(width: 5.w),
                                      Text("+2", style: theme.textTheme.bodyMedium),
                                      SizedBox(width: 5.w),
                                      Container(
                                        height: 20.h,
                                        width: 1.w,
                                        color: theme.highlightColor,
                                      ),
                                    ],
                                  ),
                                ),
                                validator: (val) =>
                                    AppValidators.validatePhoneNumber(val, l10n),
                              ),
                              SizedBox(height: 16.h),
                              DropdownButtonFormField<String>(
                                value: viewModel.selectedGender,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 15.h,
                                  ),
                                  filled: true,
                                  fillColor: theme.disabledColor,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: theme.highlightColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                iconEnabledColor: theme.highlightColor,
                                dropdownColor: theme.cardColor,
                                style: theme.textTheme.bodyMedium,
                                items: RegisterViewModel.genderOptions
                                    .map(
                                      (gender) => DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(
                                          gender == 'male' ? l10n.male : l10n.female,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: viewModel.setGender,
                                validator: (value) => value == null || value.isEmpty
                                    ? l10n.fieldRequired
                                    : null,
                              ),
                              SizedBox(height: 16.h),

                              /// PASSWORD FIELD
                              CustomTextFormField(
                                controller: viewModel.passwordCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: l10n.password,
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                obscureText: viewModel.hidePassword,
                                validator: (val) =>
                                    AppValidators.validatePassword(val, l10n),
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
                              SizedBox(height: 16.h),
                              CustomTextFormField(
                                controller: viewModel.confirmPasswordCtrl,
                                hintStyle: theme.textTheme.bodyMedium,
                                hintText: l10n.confirmPassword,
                                fillColor: theme.disabledColor,
                                borderSideColor: theme.highlightColor,
                                obscureText: viewModel.hidePassword,
                                validator: (val) => AppValidators.validateConfirmPassword(
                                  val,
                                  viewModel.passwordCtrl.text,
                                  l10n,
                                ),
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
                              SizedBox(height: 19.h),
                              CustomElevatedButtom(
                                onPressed: () {
                                  viewModel.register(userViewModel);
                                },
                                text: l10n.register,
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
                                    l10n.haveAccount,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed(AppRoutes.loginRoute);
                                    },
                                    child: Text(
                                      l10n.login,
                                      style: AppStyles.semiBold14Primary,
                                    ),
                                  ),
                                ],
                              ),
                              const LanguageToggle(),
                              SizedBox(height: 20.h),
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
