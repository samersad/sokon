import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  static TextStyle bold20black = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );
  static TextStyle bold36black = TextStyle(
    fontFamily: 'Montserrat',

    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );
  static TextStyle bold32Primary = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );
  static TextStyle semiBold20White = TextStyle(
    fontFamily: 'Montserrat',

    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );
  static TextStyle semiBold14Primary = TextStyle(
    fontFamily: 'Montserrat',

    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );
  static TextStyle bold20blackIner = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.blackColor,
  );
  static TextStyle regular14gray = TextStyle(
    fontFamily: 'Montserrat',

    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrayColor,
  );
  static TextStyle medium12gray = TextStyle(
    fontFamily: 'Montserrat',

    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.darkGrayColor,
  );
  static TextStyle regular15black = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.blackColor,
  );
  static TextStyle semiBold15black = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.blackColor,
  );
  static TextStyle regular30primary = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );
}
