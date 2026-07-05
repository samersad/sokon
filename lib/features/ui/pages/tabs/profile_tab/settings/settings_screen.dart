import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/theme_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/cubit/settings_states.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/settings/cubit/settings_view_model.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';

import '../../../../../../core/utils/app_assets.dart';
import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/phone_verification_utils.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../../../core/utils/app_validator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController collegeController;
  late TextEditingController phoneController;
  final SettingsViewModel viewModel = getIt<SettingsViewModel>();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    collegeController = TextEditingController(text: user?.college ?? "");
    phoneController = TextEditingController(
      text: PhoneVerificationUtils.displayLocal(user?.phoneNumber),
    );
    phoneController.addListener(_refreshPhoneStatus);
  }

  void _refreshPhoneStatus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    phoneController.removeListener(_refreshPhoneStatus);
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeCubit = context.read<ThemeViewModel>();
    final editableFillColor = theme.disabledColor;
    final readOnlyFillColor = theme.disabledColor.withValues(alpha: 0.45);
    return BlocConsumer<SettingsViewModel, SettingsState>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is SettingsSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
          Navigator.pop(context);
        } else if (state is SettingsPhoneVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number verified')),
          );
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
        }
      },
      builder: (context, state) {
        final user = context.read<UserViewModel>().user;
        final genderValue = user?.gender?.trim();
        final displayGender = genderValue == null || genderValue.isEmpty
            ? 'Male'
            : genderValue[0].toUpperCase() + genderValue.substring(1);
        final isPhoneVerified =
            user?.phoneVerified == true &&
            PhoneVerificationUtils.isSamePhone(
              user?.phoneNumber,
              phoneController.text,
            ) &&
            PhoneVerificationUtils.isValidEgyptianMobile(phoneController.text);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              l10n.editProfile,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: themeCubit.toggleTheme,
                icon: Icon(
                  themeCubit.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 100.h),
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70.r,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).disabledColor,
                                  backgroundImage:
                                      viewModel.profileImage != null
                                      ? FileImage(viewModel.profileImage!)
                                      : (user?.photoUrl != null &&
                                                    user!.photoUrl!.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                    user.photoUrl!,
                                                  )
                                                : AssetImage(
                                                    AppAssets.profileImage,
                                                  ))
                                            as ImageProvider,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      viewModel.pickImage(ImageSource.gallery);
                                    },
                                    child: CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor:
                                          AppColors.transparentColor,
                                      child: Image.asset(
                                        AppAssets.cameraIconProfle,
                                        scale: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 80.h),
                          Text(
                            l10n.username,
                            style: AppStyles.semiBold14DarkPrimary,
                          ),
                          SizedBox(height: 5.h),
                          CustomTextFormField(
                            hintText: l10n.username,
                            controller: nameController,
                            paddingVertical: 15.h,
                            borderSideColor: AppColors.grayColor,
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            fillColor: editableFillColor,
                            validator: (val) =>
                                AppValidators.validateFullName(val, l10n),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            l10n.email,
                            style: AppStyles.semiBold14DarkPrimary,
                          ),
                          SizedBox(height: 5.h),
                          CustomTextFormField(
                            hintText: l10n.email,
                            controller: emailController,
                            paddingVertical: 15.h,
                            borderSideColor: AppColors.grayColor,
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            fillColor: readOnlyFillColor,
                            readOnly: true,
                          ),
                          SizedBox(height: 20.h),
                          if (user?.role != 'owner') ...[
                            Text(
                              l10n.college,
                              style: AppStyles.semiBold14DarkPrimary,
                            ),
                            SizedBox(height: 5.h),
                            CustomTextFormField(
                              hintText: l10n.college,
                              controller: collegeController,
                              paddingVertical: 15.h,
                              borderSideColor: AppColors.grayColor,
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              fillColor: editableFillColor,
                            ),
                            SizedBox(height: 20.h),
                          ],
                          Text(
                            l10n.phoneNumber,
                            style: AppStyles.semiBold14DarkPrimary,
                          ),
                          SizedBox(height: 5.h),
                          CustomTextFormField(
                            hintText: l10n.phoneNumber,
                            controller: phoneController,
                            borderSideColor: theme.highlightColor,
                            hintStyle: theme.textTheme.bodyMedium,
                            fillColor: theme.disabledColor,
                            keyboardType: TextInputType.phone,
                            prefixIconName: Container(
                              width: 80.w,
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                children: [
                                  Text(
                                    "🇪🇬",
                                    style: TextStyle(fontSize: 20.sp),
                                  ),
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
                          SizedBox(height: 10.h),
                          _buildPhoneVerificationStatus(
                            context,
                            isPhoneVerified,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            l10n.gender,
                            style: AppStyles.semiBold14DarkPrimary,
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 15.h,
                            ),
                            decoration: BoxDecoration(
                              color: readOnlyFillColor,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColors.grayColor),
                            ),
                            child: Text(
                              displayGender,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          SizedBox(height: 70.h),
                          CustomElevatedButtom(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                viewModel.saveChanges(
                                  nameController.text,
                                  phoneController.text,
                                  user?.role == 'owner'
                                      ? null
                                      : collegeController.text,
                                );
                              }
                            },
                            text: l10n.saveChanges,
                            width: 500.w,
                            borderRadius: 10.r,
                            backgroundColorElevated: AppColors.darkBlueColor,
                            textStyle: AppStyles.semiBold20White,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state is SettingsLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneVerificationStatus(
    BuildContext context,
    bool isPhoneVerified,
  ) {
    final theme = Theme.of(context);
    final statusColor = isPhoneVerified ? Colors.green : AppColors.redMaterial;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isPhoneVerified ? Icons.verified_outlined : Icons.error_outline,
            color: statusColor,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isPhoneVerified ? 'Phone verified' : 'Phone not verified',
              style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
            ),
          ),
          if (!isPhoneVerified)
            TextButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                final channel = await _chooseOtpChannel(context);
                if (!context.mounted || channel == null) return;
                await Future<void>.delayed(const Duration(milliseconds: 1));

                try {
                  await viewModel.requestPhoneVerificationOTP(
                    phoneController.text,
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
                await _showPhoneOtpDialog(context, channel: channel);
              },
              child: const Text('Verify'),
            ),
        ],
      ),
    );
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
    BuildContext context, {
    required String channel,
  }) {
    final phone = phoneController.text;
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
                  child: const Text('Cancel'),
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
                      await viewModel.verifyPhoneOTP(phone, otp);
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
