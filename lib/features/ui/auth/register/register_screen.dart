import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../core/di/di.dart';
import '../../../../core/model/RegisterResponse.dart';
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            _showPhoneVerificationChoice(context, state.user, userViewModel);
          });
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
                    Center(
                      child: Text(
                        l10n.signUp,
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
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
                                initialValue: viewModel.selectedRole,
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
                                          role == 'owner'
                                              ? l10n.owner
                                              : l10n.client,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: viewModel.setRole,
                                validator: (value) =>
                                    value == null || value.isEmpty
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
                                  validator: (val) =>
                                      AppValidators.validateFullName(val, l10n),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "🇪🇬",
                                        style: TextStyle(fontSize: 20.sp),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        "+2",
                                        style: theme.textTheme.bodyMedium,
                                      ),
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
                                    AppValidators.validatePhoneNumber(
                                      val,
                                      l10n,
                                    ),
                              ),
                              SizedBox(height: 16.h),
                              DropdownButtonFormField<String>(
                                initialValue: viewModel.selectedGender,
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
                                          gender == 'male'
                                              ? l10n.male
                                              : l10n.female,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: viewModel.setGender,
                                validator: (value) =>
                                    value == null || value.isEmpty
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
                                validator: (val) =>
                                    AppValidators.validateConfirmPassword(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed(
                                        AppRoutes.loginRoute,
                                      );
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

  Future<void> _goHome(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.homeScreenRoute, (route) => false);
  }

  Future<void> _showPhoneVerificationChoice(
    BuildContext context,
    RegisterUser user,
    UserViewModel userViewModel,
  ) async {
    final phone = user.phoneNumber?.toString();
    FocusManager.instance.primaryFocus?.unfocus();
    final shouldVerify = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verify phone number?'),
          content: Text(
            'You can skip now, but you must verify $phone before renting any apartment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip for now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;
    if (shouldVerify == true) {
      final channel = await _chooseOtpChannel(context);
      if (!context.mounted) return;
      if (channel == null) {
        await _goHome(context);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
      if (!context.mounted) return;

      try {
        await viewModel.requestPhoneVerificationOTP(
          phone ?? '',
          channel: channel,
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
        return;
      }
      if (!context.mounted) return;

      final verified = await _showPhoneOtpDialog(
        context,
        phone,
        channel: channel,
        userViewModel: userViewModel,
      );
      if (verified == true) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Phone number verified')));
      }
    }
    if (!context.mounted) return;
    await _goHome(context);
  }

  Future<String?> _chooseOtpChannel(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Send verification code'),
          content: const Text('Choose how you want to receive the OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('sms'),
              child: const Text('SMS'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('whatsapp'),
              child: const Text('WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showPhoneOtpDialog(
    BuildContext context,
    String? phone, {
    required String channel,
    required UserViewModel userViewModel,
  }) {
    final codeController = TextEditingController();
    String? errorText;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Phone verification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter the 6-digit code for $phone.'),
                    Text(
                      'Sent by ${channel == 'whatsapp' ? 'WhatsApp' : 'SMS'}.',
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Verification code',
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final otp = codeController.text.trim();
                    if (otp.length != 6) {
                      setDialogState(() {
                        errorText = 'Enter the 6-digit code';
                      });
                      return;
                    }
                    try {
                      await viewModel.verifyPhoneOTP(
                        phone ?? '',
                        otp,
                        userViewModel,
                      );
                      if (!dialogContext.mounted) return;
                      await Future<void>.delayed(
                        const Duration(milliseconds: 80),
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                      return;
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      setDialogState(() {
                        errorText = e.toString();
                      });
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(codeController.dispose);
  }
}
