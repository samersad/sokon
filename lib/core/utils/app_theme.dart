import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(

    scaffoldBackgroundColor: AppColors.whiteColor,
    focusColor: AppColors.whiteColor,
    canvasColor: AppColors.whiteColor,
    primaryColor: AppColors.primaryLight,
    cardColor: AppColors.whiteColor,
    dividerColor: AppColors.grayColor,
    highlightColor: AppColors.grayColor,
    disabledColor: AppColors.offWhiteColor,
    splashColor: AppColors.redColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.whiteColor,
      foregroundColor: AppColors.blackColor,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyles.bold20black

        ,
      headlineMedium: AppStyles.medium16black,
      headlineSmall: AppStyles.bold10black,
      bodyMedium: AppStyles.medium16black,
      bodySmall: AppStyles.semiBold14White,
      labelMedium: AppStyles.medium16black,
      displaySmall: AppStyles.bold14Primary,
      labelSmall: AppStyles.medium16primary,
      labelLarge: AppStyles.bold18PrimaryColor,
      titleSmall: AppStyles.bold20black,
      titleMedium: AppStyles.medium16primary,
      titleLarge: AppStyles.semiBold20White,



    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryLight,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.whiteColor,
      unselectedItemColor: AppColors.whiteColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: AppStyles.bold12White,
      unselectedLabelStyle: AppStyles.bold12White,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.whiteColor, width: 4),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(

    splashColor: AppColors.whiteColor,
    primaryColor: AppColors.whiteColor,
    scaffoldBackgroundColor: AppColors.primaryDark,
    focusColor: AppColors.primaryLight,
    canvasColor: AppColors.transparentColor,
    cardColor: AppColors.darkPrimaryColor,
    dividerColor: AppColors.primaryLight,
    highlightColor: AppColors.whiteColor,
    disabledColor: AppColors.darkPrimaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      headlineLarge: AppStyles.bold20black.copyWith(color: AppColors.whiteColor),
      headlineMedium: AppStyles.medium16black.copyWith(color: AppColors.whiteColor),
      headlineSmall: AppStyles.bold10black.copyWith(color: AppColors.whiteColor),
      bodyMedium: AppStyles.medium16black.copyWith(color: AppColors.whiteColor),
      bodySmall: AppStyles.medium16primary,
      labelMedium: AppStyles.medium16black.copyWith(color: AppColors.whiteColor),
      displaySmall: AppStyles.bold14Primary.copyWith(color: AppColors.whiteBlue),
      titleSmall: AppStyles.bold20black.copyWith(color: AppColors.redColor),
      labelLarge: AppStyles.bold18PrimaryColor,
      titleMedium: AppStyles.semiBold14White,
      titleLarge: AppStyles.semiBold20White.copyWith(color: AppColors.blackColor),


      labelSmall: AppStyles.medium16primary.copyWith(
        color: AppColors.whiteColor,
      ),


    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryDark,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.whiteColor,
      unselectedItemColor: AppColors.whiteColor,
      selectedLabelStyle: AppStyles.bold12White,
      unselectedLabelStyle: AppStyles.bold12White,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      shape: const StadiumBorder(
        side: BorderSide(color: AppColors.whiteColor, width: 4),
      ),
    ),
  );
}
