import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import 'cubit/home_screen_states.dart';
import 'cubit/home_screen_view_model.dart';

class HomeScreen extends StatefulWidget {
  static const homeScreenRouteNamed = "home_screen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    HomeScreenViewModel viewModel = HomeScreenViewModel();

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();
    bool isOwner = userViewModel.user?.role == 'owner';

    return BlocBuilder<HomeScreenViewModel, HomeScreenStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            gapWidth: isOwner ? 50 : 0,
            backgroundColor: AppColors.whiteColor,
            itemCount: viewModel.selectedIcon.length,
            leftCornerRadius: 36.r,
            rightCornerRadius: 36.r,
            tabBuilder: (int index, bool isActive) {
              return viewModel.selectedIndex == index
                  ? Image.asset(
                      viewModel.selectedIcon[index],
                      width: 35.w,
                      height: 35.h,
                    )
                  : Image.asset(
                      viewModel.unSelectedIcon[index],
                      width: 35.w,
                      height: 35.h,
                    );
            },
            activeIndex: viewModel.selectedIndex,
            gapLocation: isOwner ? GapLocation.center : GapLocation.none,
            notchSmoothness: NotchSmoothness.smoothEdge,
            elevation: 0,
            onTap: (index) => viewModel.changeTabIndex(index),
          ),
          floatingActionButton: isOwner
              ? FloatingActionButton(
                  backgroundColor: AppColors.blackColor,
                  shape: const CircleBorder(),
                  elevation: 0,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.addApartmentRoute);
                  },
                  child: Icon(
                    Icons.add,
                    color: AppColors.whiteColor,
                    size: 40.r,
                  ),
                )
              : null,
          floatingActionButtonLocation: isOwner
              ? FloatingActionButtonLocation.centerDocked
              : FloatingActionButtonLocation.endFloat,
          body: viewModel.tabs[viewModel.selectedIndex],
        );
      },
    );
  }
}
