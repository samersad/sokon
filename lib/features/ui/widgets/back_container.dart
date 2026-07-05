import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
class BackContainer extends StatelessWidget {
  const BackContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 58.w,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          color: AppColors.disabledGrayColor,
        ),
        child: Image.asset(AppAssets.backArrow),
      ),
    );

  }
}
