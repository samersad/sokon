import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppStyles {
  // Common Font Families
  static const String montserrat = 'Montserrat';
  static const String poppins = 'Poppins';
  static const String lato = 'Lato';
  static const String inter = 'Inter';
  static const String outfit = 'Outfit';
  static const String raleway = 'Raleway';

  // Black Styles
  static TextStyle bold36black = TextStyle(
    fontFamily: montserrat,
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor, 
  );

  static TextStyle bold20black = TextStyle(
    fontFamily: montserrat,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );

  static TextStyle bold20blackIner = TextStyle(
    fontFamily: inter,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );

  static TextStyle medium16black = TextStyle(
    fontFamily: poppins,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blackColor,
  );

  static TextStyle regular15black = TextStyle(
    fontFamily: outfit,
    fontSize: 15.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.blackColor,
  );

  static TextStyle semiBold15black = TextStyle(
    fontFamily: outfit,
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blackColor,
  );

  static TextStyle regular14black = TextStyle(
    fontFamily: montserrat,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.blackColor,
  );
  static TextStyle bold12White = TextStyle(
    fontFamily: montserrat,
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  static TextStyle bold10black = TextStyle(
    fontFamily: montserrat,
    fontSize: 10.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );

  // Primary Color Styles
  static TextStyle bold32Primary = TextStyle(
    fontFamily: montserrat,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle bold24Primary = TextStyle(
    fontFamily: lato,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle regular30primary = TextStyle(
    fontFamily: outfit,
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );

  static TextStyle bold18PrimaryColor = TextStyle(
    fontFamily: lato,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle bold16PrimaryColor = TextStyle(
    fontFamily: raleway,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle semiBold14Primary = TextStyle(
    fontFamily: montserrat,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );

  static TextStyle medium13PrimaryColor = TextStyle(
    fontFamily: raleway,
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );

  static TextStyle bold12Primary = TextStyle(
    fontFamily: raleway,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle bold12PrimaryColor = TextStyle(
    fontFamily: raleway,
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryColor,
  );

  static TextStyle semiBold10PrimaryColor = TextStyle(
    fontFamily: raleway,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );

  static TextStyle bold10Primary = TextStyle(
    fontFamily: montserrat,
    fontSize: 10.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle bold14Primary = TextStyle(
    fontFamily: raleway,
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static TextStyle bold8Primary = TextStyle(
    fontFamily: montserrat,
    fontSize: 8.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  // Gray Styles
  static TextStyle regular14gray = TextStyle(
    fontFamily: montserrat,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrayColor,
  );

  static TextStyle regular12gray = TextStyle(
    fontFamily: montserrat,
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrayColor,
  );

  static TextStyle medium12gray = TextStyle(
    fontFamily: montserrat,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.darkGrayColor,
  );

  static TextStyle medium13Gray = TextStyle(
    fontFamily: poppins,
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.grayColor,
  );

  static TextStyle medium13GrayWithOpacity = TextStyle(
    fontFamily: poppins,
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blackColor.withOpacity(0.5),
  );

  // White Styles
  static TextStyle semiBold20White = TextStyle(
    fontFamily: montserrat,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );

  static TextStyle semiBold14White = TextStyle(
    fontFamily: montserrat,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );

  static TextStyle medium12White = TextStyle(
    fontFamily: montserrat,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.whiteColor,
  );

  // Blue / Dark Color Styles
  static TextStyle medium16whiteBlue = TextStyle(
    fontFamily: raleway,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.redColor,
  );
  static TextStyle medium16primary = TextStyle(
    fontFamily: raleway,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );
  static TextStyle medium13blue = TextStyle(
    fontFamily: poppins,
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blueColor,
  );

  static TextStyle medium10blueDarkColor = TextStyle(
    fontFamily: raleway,
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blueDarkColor,
  );

  static TextStyle semiBold14DarkPrimary = TextStyle(
    fontFamily: inter,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.darkPrimaryColor,
  );

  // Other
  static TextStyle medium16RedColor = TextStyle(
    fontFamily: inter,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.redColor,
  );
}
