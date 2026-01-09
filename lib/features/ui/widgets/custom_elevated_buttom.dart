
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';

class CustomElevatedButtom extends StatelessWidget {
  CustomElevatedButtom({super.key, required this.onPressed,
    this.text,
    this.backgroundColorElevated=AppColors.primaryColor,this.iconName,
    this.textStyle,
    this.borderColor=AppColors.transparentColor,this.hasIcon=false,this.mainAxisAlignment,this.childIconWidget,
    this.customPadding=20,
  this.width,
  this.borderRadius=20});
  //final VoidCallback onPressed;
  final  String? text;

  final Color backgroundColorElevated;
  final void Function() onPressed ;
  final Widget? iconName;
  final Widget? childIconWidget;
  final TextStyle? textStyle;

  final Color? borderColor;

  final bool hasIcon;

  MainAxisAlignment? mainAxisAlignment;

  final double customPadding;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(onPressed: onPressed,

          style: ElevatedButton.styleFrom(
            fixedSize: Size.fromWidth(width!),
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: customPadding),
            backgroundColor: backgroundColorElevated,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor!,width: 2.w),
              borderRadius: BorderRadiusGeometry.circular(borderRadius),
            ),
          ),
          child: hasIcon?
          childIconWidget
              :
          Text(text??"",style: textStyle ??AppStyles.bold20black)

      ),
    );
  }
}
