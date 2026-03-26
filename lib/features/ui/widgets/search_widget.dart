import 'package:flutter/material.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';
import 'custom_text_form_field.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key,required this.hintText});
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      paddingVertical: 20,
      borderRadius: 14,
      fillColor: AppColors.whiteColor,
      borderSideColor: AppColors.grayColor,
      hintText: hintText,
      hintStyle: AppStyles.medium12gray,
      prefixIconName: Image.asset(AppAssets.searchIcon),
      suffixIconName: InkWell(
        onTap: () {},
        child: Image.asset(AppAssets.filterIcon),
      ),
    );
  }
}
