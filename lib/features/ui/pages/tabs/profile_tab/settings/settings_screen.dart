import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../../widgets/custom_text_form_field.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  final SettingsViewModel viewModel = getIt<SettingsViewModel>();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeViewModel>();
    return BlocConsumer<SettingsViewModel, SettingsState>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is SettingsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context);
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.message}")),
          );
        }
      },
      builder: (context, state) {
        final user = context.read<UserViewModel>().user;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: themeCubit.toggleTheme,
                icon: Icon(
                  themeCubit.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 100.h),
                        Center(
                          child: Stack(
                            children: [
                        CircleAvatar(
                          radius: 70.r,
                                backgroundColor: Theme.of(context).disabledColor,
                                backgroundImage: viewModel.profileImage != null
                                    ? FileImage(viewModel.profileImage!)
                                    : (user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                        ? NetworkImage(user.photoUrl!)
                                        : AssetImage(AppAssets.profileImage)) as ImageProvider,
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
                                    backgroundColor: AppColors.transparentColor,
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
                        Text("Username", style: AppStyles.semiBold14DarkPrimary),
                        SizedBox(height: 5.h),
                        CustomTextFormField(
                          hintText: "Username",
                          controller: nameController,
                          paddingVertical: 15.h,
                          borderSideColor: AppColors.grayColor,
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          fillColor: Theme.of(context).disabledColor,
                        ),
                        SizedBox(height: 20.h),
                        Text("Email", style: AppStyles.semiBold14DarkPrimary),
                        SizedBox(height: 5.h),
                        CustomTextFormField(
                          hintText: "Email",
                          controller: emailController,
                          paddingVertical: 15.h,
                          borderSideColor: AppColors.grayColor,
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          fillColor: Theme.of(context).disabledColor,
                        ),
                        SizedBox(height: 70.h),
                        CustomElevatedButtom(
                          onPressed: () {
                            viewModel.saveChanges(nameController.text);
                          },
                          text: "Save Change",
                          width: 500.w,
                          borderRadius: 10.r,
                          backgroundColorElevated: AppColors.darkBlueColor,
                          textStyle: AppStyles.semiBold20White,
                        )
                      ],
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
}
