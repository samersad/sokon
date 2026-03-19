import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../tabs/home_tab/home_tab.dart';
import '../tabs/message_tab/message_tab.dart';
import '../tabs/profile_tab/profile_tab.dart';
import '../tabs/search_tab/search_tab.dart';

class HomeScreen extends StatefulWidget {
  static const homeScreenRouteNamed = "home_screen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<Widget> tabs = [
    const HomeTab(),
    const SearchTab(),
    const MessageTab(),
    const ProfileTab(),
  ];

  List<String> unSelectedIcon = [
    AppAssets.unselectedHomeIcon,
    AppAssets.unselectedSearchIcon,
    AppAssets.unselectedMessageIcon,
    AppAssets.unselectedProfileIcon,
  ];
  List<String> selectedIcon = [
    AppAssets.selectedHomeIcon,
    AppAssets.selectedSearchIcon,
    AppAssets.selectedMessageIcon,
    AppAssets.selectedProfileIcon,
  ];

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    bool isOwner = userProvider.user?.role == 'owner';

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        gapWidth: isOwner ? 50 : 0,
        backgroundColor: AppColors.whiteColor,
        itemCount: selectedIcon.length,
        leftCornerRadius: 36.r,
        rightCornerRadius: 36.r,
        tabBuilder: (int index, bool isActive) {
          return selectedIndex == index
              ? Image.asset(
                  selectedIcon[index],
                  width: 35.w,
                  height: 35.h,
                )
              : Image.asset(
                  unSelectedIcon[index],
                  width: 35.w,
                  height: 35.h,
                );
        },
        activeIndex: selectedIndex,
        gapLocation: isOwner ? GapLocation.center : GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        elevation: 0,
        onTap: (index) => setState(() => selectedIndex = index),
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
      body: tabs[selectedIndex],
    );
  }

  Widget builtBottomNavItem({required int index, required String iconName}) {
    return selectedIndex == index
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: ImageIcon(AssetImage(iconName)))
        : ImageIcon(AssetImage(iconName));
  }
}
