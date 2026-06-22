import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.blueColor,
      surface: AppColors.whiteColor,
      error: AppColors.redColor,
    ),
    scaffoldBackgroundColor: AppColors.addApartmentLightBackground,
    focusColor: AppColors.whiteColor,
    canvasColor: AppColors.whiteColor,
    primaryColor: AppColors.primaryLight,
    cardColor: AppColors.whiteColor,
    dividerColor: AppColors.grayColor,
    highlightColor: AppColors.grayColor,
    disabledColor: AppColors.addApartmentLightField,
    splashColor: AppColors.redColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.whiteColor,
      foregroundColor: AppColors.blackColor,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.addApartmentLightField,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.redColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.redColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.whiteBlue,
        foregroundColor: AppColors.whiteColor,
        shadowColor: AppColors.primaryColor.withOpacity(0.3),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
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
    useMaterial3: false,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.whiteBlue,
      secondary: AppColors.whiteBlue,
      surface: AppColors.addApartmentDarkSurface,
      error: AppColors.redColor,
    ),
    splashColor: AppColors.whiteColor,
    primaryColor: AppColors.whiteBlue,
    scaffoldBackgroundColor: AppColors.addApartmentDarkBackground,
    focusColor: AppColors.primaryLight,
    canvasColor: AppColors.transparentColor,
    cardColor: AppColors.addApartmentDarkSurface,
    dividerColor: AppColors.primaryLight,
    highlightColor: AppColors.whiteColor,
    disabledColor: AppColors.addApartmentDarkField,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.addApartmentDarkBackground,
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.addApartmentDarkField,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.whiteBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.redColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.redColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.whiteBlue,
        foregroundColor: AppColors.whiteColor,
        shadowColor: AppColors.whiteBlue.withOpacity(0.3),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
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
