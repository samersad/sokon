import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_routes.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';

class NearbyEstateCard extends StatelessWidget {
  const NearbyEstateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.apartmentDetailsRoute),
      child: Container(
        width: 168.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(27),
        ),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                AppAssets.imageC,
                fit: BoxFit.cover,
              ),
            ),
      
            SizedBox(height: 8.h),
      
            Text(
              "Bungalow House",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.bold12Primary,
            ),
      
            SizedBox(height: 6.h),
      
            Row(
              children: [
                Image.asset(AppAssets.locationOrange, width: 14.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "Jakarta, Indonesia",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.medium10blueDarkColor,
                  ),
                ),
                Image.asset(AppAssets.downIcon, width: 12.w),
              ],
            ),
      
            SizedBox(height: 10.h),
      
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "EG 290/",
                        style: AppStyles.bold18PrimaryColor,
                      ),
                      TextSpan(
                        text: "month",
                        style: AppStyles.bold8Primary,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Image.asset(AppAssets.star, width: 14.w),
                SizedBox(width: 4.w),
                Text("4.7", style: AppStyles.bold12Primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
