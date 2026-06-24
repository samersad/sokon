import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/user_states.dart';
import 'package:sokon/core/cache/cubit_manger/theme_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/cubit/profile_states.dart';
import 'package:sokon/features/ui/pages/tabs/profile_tab/cubit/profile_view_model.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';
import 'package:sokon/features/ui/widgets/custom_elevated_buttom.dart';
import 'package:sokon/features/ui/widgets/language_toggle.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ProfileViewModel viewModel = getIt<ProfileViewModel>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ProfileViewModel, ProfileStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is ProfileLoading) {
          AlertDialogUtils.showLoading(context: context, msg: l10n.pleaseWait);
        } else if (state is ProfileLogoutSuccess) {
          AlertDialogUtils.hideLoading(context: context);
          Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.loginRoute, (route) => false);
        } else if (state is ProfileDeleteAccountSuccess) {
          AlertDialogUtils.hideLoading(context: context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.accountDeletedSuccess)),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.loginRoute, (route) => false);
        } else if (state is ProfileError) {
          AlertDialogUtils.hideLoading(context: context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ProfileViewModel, ProfileStates>(
        bloc: viewModel,
        builder: (context, profileState) {
          final theme = Theme.of(context);
          final themeCubit = context.read<ThemeViewModel>();
          return BlocBuilder<UserViewModel, UserState>(
            builder: (context, state) {
              var userViewModel = context.read<UserViewModel>();
              var user = userViewModel.user;
              bool isOwner = user?.role == 'owner';
              bool isClient = user?.role == 'client';
              String? photoUrl = user?.photoUrl;

              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 60.h),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primaryColor, width: 3.w),
                                  ),
                                  child: CircleAvatar(
                                    radius: 70.r,
                                    backgroundColor: theme.disabledColor,
                                    backgroundImage: (photoUrl != null &&
                                            photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : AssetImage(AppAssets.profileImage))
                                        as ImageProvider,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(user?.name ?? l10n.noName,
                              style: theme.textTheme.bodyMedium),
                          SizedBox(height: 5.h),
                          Text(_formatRole(user?.role), style: theme.textTheme.bodyMedium),
                          SizedBox(height: 5.h),
                          Text(user?.email ?? l10n.noEmail,
                              style: theme.textTheme.bodyMedium),
                          SizedBox(height: 40.h),
                          Divider(color: theme.dividerColor.withValues(alpha: 0.3), thickness: 1.h),
                          SizedBox(height: 20.h),
                          buildRowTile(
                            icon: Icons.settings_outlined,
                            title: l10n.settings,
                            color: Colors.blue,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.settingsScreenRoute),
                          ),
                          SizedBox(height: 20.h),
                          buildRowTile(
                            icon: themeCubit.isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            title: themeCubit.isDark ? "Dark Mode" : "Light Mode",
                            color: theme.primaryColor,
                            onTap: () => _showThemeSheet(context, themeCubit),
                          ),
                          SizedBox(height: 20.h),
                          buildRowTile(
                            icon: Icons.payment_outlined,
                            title: l10n.payment,
                            color: Colors.orange,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.addCardRoute),
                          ),
                          if (isClient) ...[
                            SizedBox(height: 20.h),
                            buildRowTile(
                              icon: Icons.bookmark_border_outlined,
                              title: l10n.myBookings,
                              color: Colors.pink,
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.myBookingsRoute);
                              },
                            ),
                          ],
                          if (isOwner) ...[
                            SizedBox(height: 20.h),
                            buildRowTile(
                              icon: Icons.assignment_outlined,
                              title: l10n.bookingRequests,
                              color: Colors.indigo,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.ownerBookingRequestsRoute,
                                );
                              },
                            ),
                            SizedBox(height: 20.h),
                            buildRowTile(
                              icon: Icons.apartment_outlined,
                              title: l10n.myApartments,
                              color: Colors.green,
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.myApartmentsRoute);
                              },
                            ),
                          ],
                          SizedBox(height: 20.h),
                          buildRowTile(
                            icon: Icons.notifications_none_outlined,
                            title: l10n.notification,
                            color: Colors.purple,
                            onTap: () {Navigator.of(context).pushNamed(AppRoutes.notificationRoute);},
                          ),
                          SizedBox(height: 20.h),
                          buildRowTile(
                            icon: Icons.info_outline,
                            title: l10n.about,
                            color: Colors.teal,
                            onTap: () {},
                          ),
                          SizedBox(height: 30.h),
                          const LanguageToggle(),
                          SizedBox(height: 40.h),
                          TextButton(
                              onPressed: () => viewModel.logout(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout,
                                      color: AppColors.redColor, size: 20.sp),
                                  SizedBox(width: 5.w),
                                  Text(
                                    l10n.logout,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.redColor),
                                  ),
                                ],
                              )),
                          SizedBox(height: 10.h),
                          TextButton(
                            onPressed: () {
                              _showDeleteAccountDialog(context, l10n);
                            },
                            child: Text(
                              l10n.deleteAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.redColor),
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildRowTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(title, style: theme.textTheme.labelMedium),
            ),
            Icon(Icons.arrow_forward_ios,
                color: theme.highlightColor, size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, ThemeViewModel themeCubit) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        final currentTheme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Theme", style: currentTheme.textTheme.displaySmall),
                SizedBox(height: 12.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.light_mode_outlined),
                  title: Text("Light Mode", style: currentTheme.textTheme.labelMedium),
                  trailing: themeCubit.isDark ? null : Icon(Icons.check, color: currentTheme.primaryColor),
                  onTap: () {
                    themeCubit.setDark(dark: false);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text("Dark Mode", style: currentTheme.textTheme.labelMedium),
                  trailing: themeCubit.isDark ? Icon(Icons.check, color: currentTheme.primaryColor) : null,
                  onTap: () {
                    themeCubit.setDark(dark: true);
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRole(String? role) {
    final value = role?.trim();
    if (value == null || value.isEmpty) {
      return "No Role";
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    final passwordController = TextEditingController();
    final theme = Theme.of(context);
    final user = context.read<UserViewModel>().user;
    final requiresPassword = user?.authProvider != 'google';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(l10n.deleteAccountTitle, style: AppStyles.bold20blackIner),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountWarning,
                style: AppStyles.medium16black,
              ),
              if (requiresPassword) ...[
                SizedBox(height: 20.h),
                Text(
                  l10n.enterPasswordToConfirm,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.redColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actionsPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButtom(
                    onPressed: () => Navigator.pop(dialogContext),
                    borderRadius: 10,
                    text: l10n.cancel,
                    textStyle: AppStyles.semiBold14White,
                    width: 120.w,
                    backgroundColorElevated: AppColors.grayColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomElevatedButtom(
                    onPressed: () {
                      final password = requiresPassword
                          ? passwordController.text.trim()
                          : null;
                      if (requiresPassword &&
                          (password == null || password.isEmpty)) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pleaseEnterPassword),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext);
                      viewModel.deleteAccount(password);
                    },
                    text: l10n.delete,
                    textStyle: AppStyles.semiBold14White,
                    borderRadius: 10,
                    width: 120.w,
                    backgroundColorElevated: AppColors.redColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
