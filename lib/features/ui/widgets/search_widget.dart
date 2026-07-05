import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_styles.dart';
import 'custom_text_form_field.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomTextFormField(
      controller: controller,
      onChanged: onChanged,
      paddingVertical: 18.h,
      borderRadius: 14,
      fillColor: theme.disabledColor,
      borderSideColor: theme.highlightColor,
      hintText: hintText,
      hintStyle: AppStyles.medium12gray.copyWith(color: theme.highlightColor),
      prefixIconName: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Image.asset(AppAssets.searchIcon, width: 20.w),
      ),
      suffixIconName: IconButton(
        onPressed: onFilterTap ?? () {},
        icon: Image.asset(AppAssets.filterIcon, width: 20.w),
      ),
    );
  }
}
