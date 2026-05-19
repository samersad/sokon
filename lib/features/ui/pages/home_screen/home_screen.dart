import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cubit_manger/user_view_model.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import 'cubit/home_screen_states.dart';
import 'cubit/home_screen_view_model.dart';

class HomeScreen extends StatelessWidget {
  static const homeScreenRouteNamed = "home_screen";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenViewModel viewModel = getIt<HomeScreenViewModel>();
    final userViewModel = context.read<UserViewModel>();
    final theme = Theme.of(context);
    bool isOwner = userViewModel.user?.role == 'owner';

    return BlocBuilder<HomeScreenViewModel, HomeScreenStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            gapWidth: isOwner ? 50 : 0,
            backgroundColor: theme.cardColor,
            itemCount: viewModel.selectedIcon.length,
            leftCornerRadius: 36.r,
            rightCornerRadius: 36.r,
            tabBuilder: (int index, bool isActive) {
              final isDarkMode = theme.brightness == Brightness.dark;
              final isSelected = viewModel.selectedIndex == index;
              return Image.asset(
                isSelected
                    ? viewModel.selectedIcon[index]
                    : viewModel.unSelectedIcon[index],
                width: 35.w,
                height: 35.h,
                color: isDarkMode
                    ? (isSelected ? Colors.white : Colors.white.withOpacity(0.4))
                    : null,
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
                  backgroundColor: theme.primaryColor,
                  shape: const CircleBorder(),
                  elevation: 0,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.addApartmentRoute);
                  },
                  child: Icon(
                    Icons.add,
                    color: theme.focusColor,
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
