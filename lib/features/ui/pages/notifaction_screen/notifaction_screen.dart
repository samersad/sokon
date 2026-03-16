import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';

class NotifactionScreen extends StatelessWidget {
  const NotifactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackContainer(),
                SizedBox(height: 20.h),
                Text("Notification", style: AppStyles.bold24Primary),
                SizedBox(height: 20.h),
                Text("Today", style: AppStyles.bold18PrimaryColor),
                SizedBox(height: 10.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => Container(
                    height: 130.h,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: AppColors.grayColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(39),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor: AppColors.transparentColor,
                          child: Image.asset(
                            AppAssets.avatar,
                            width: 64.w,
                            height: 64.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Emmett Perry",
                                style: AppStyles.bold16PrimaryColor,
                              ),
                              SizedBox(height: 5.h),
                              AutoSizeText(
                                "Just messaged you. Check the message in message tab",
                                style: AppStyles.medium12gray,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              SizedBox(height: 15.h),

                              Text(
                                "10 mins ago",
                                style: AppStyles.medium12gray,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10.h);
                  },
                  itemCount: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
