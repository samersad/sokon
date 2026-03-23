import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../tabs/home_tab/home_tab.dart';
import '../../tabs/message_tab/message_tab.dart';
import '../../tabs/profile_tab/profile_tab.dart';
import '../../tabs/search_tab/search_tab.dart';
import 'home_screen_states.dart';

class HomeScreenViewModel extends Cubit<HomeScreenStates> {
  HomeScreenViewModel() : super(HomeScreenInitial());
  final List<Widget> tabs = [
    const HomeTab(),
    const SearchTab(),
    const MessageTab(),
    const ProfileTab(),
  ];

  final List<String> unSelectedIcon = [
    AppAssets.unselectedHomeIcon,
    AppAssets.unselectedSearchIcon,
    AppAssets.unselectedMessageIcon,
    AppAssets.unselectedProfileIcon,
  ];
  final List<String> selectedIcon = [
    AppAssets.selectedHomeIcon,
    AppAssets.selectedSearchIcon,
    AppAssets.selectedMessageIcon,
    AppAssets.selectedProfileIcon,
  ];
  int selectedIndex = 0;

  void changeTabIndex(int index) {
    selectedIndex = index;
    emit(ChangeTabIndexState(index));
  }
}
