import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField({
    super.key,
    this.borderSideColor,
    this.hintText,
    this.labelText,
    this.hintStyle,
    this.labelStyle,
    this.prefixIconName,
    this.suffixIconName,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.obscuringCharacter = '•',
     this.controller,
    this.prefixIconColor,
    this.suffixIconColor,
    this.maxLines=1,
    this.onChanged, this.fillColor,
    this.borderRadius=10,
    this.paddingVertical=10,
    this.paddingHorizontal=20
  });
//
  final Color? borderSideColor;
  final Color? fillColor;
  final String? hintText;
  final String? labelText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Widget? prefixIconName;
  final Widget? suffixIconName;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String obscuringCharacter;
  final TextEditingController? controller;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final int maxLines;
  void Function(String)? onChanged ;
  final double borderRadius ;

  final double paddingVertical ;
  final double paddingHorizontal ;



  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      cursorColor: AppColors.primaryColor,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      controller: widget.controller,
      obscuringCharacter: widget.obscuringCharacter,
      cursorErrorColor: AppColors.redColor,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        contentPadding:EdgeInsetsGeometry.symmetric(vertical:  widget.paddingVertical.h,horizontal: widget.paddingHorizontal.w) ,
        fillColor:widget.fillColor??AppColors.offWhiteColor,
        filled: true,
        enabledBorder: bulitOutLineInputBorder(
          borderSideColor: widget.borderSideColor ?? AppColors.primaryColor,
          radius: widget.borderRadius,
        ),
        focusedBorder: bulitOutLineInputBorder(
          borderSideColor: widget.borderSideColor ?? AppColors.primaryColor,
        ),

        errorBorder: bulitOutLineInputBorder(borderSideColor: AppColors.redColor),
        focusedErrorBorder: bulitOutLineInputBorder(borderSideColor: AppColors.redColor),
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.bodyMedium,
        labelText: widget.labelText,
        labelStyle: widget.labelStyle ?? Theme.of(context).textTheme.bodyMedium,
        prefixIcon: widget.prefixIconName,
        prefixIconColor: Theme.of(context).highlightColor,
        suffixIcon: widget.suffixIconName,
        suffixIconColor: Theme.of(context).highlightColor,
      ),
    );
  }

  OutlineInputBorder bulitOutLineInputBorder({required Color borderSideColor,double radius=10}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderSideColor, width: 1),
    );
  }
}
