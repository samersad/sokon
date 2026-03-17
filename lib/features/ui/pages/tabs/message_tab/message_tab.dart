import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/features/ui/widgets/search_widget.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../widgets/back_container.dart';

class MessageTab extends StatelessWidget {
  const MessageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Messages", style: AppStyles.bold24Primary),

              SizedBox(height: 20.h),
              SearchWidget(hintText: "Search"),
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) => Container(
                    height: 100.h,
                    padding: EdgeInsets.all(20.sp),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(70.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                          ),
                          child: Image.asset(
                            AppAssets.messageImage,
                            fit: BoxFit.cover,
                            width: 65.sp,
                            height: 65.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Emmett Perry",
                                    style: AppStyles.bold16PrimaryColor,
                                  ),
                                  Spacer(),
                                  Text(
                                    "12:30 AM",
                                    style: AppStyles.bold12Primary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              AutoSizeText(
                                "Okay, take care dear...",
                                style: AppStyles.medium12gray,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                  itemCount: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
