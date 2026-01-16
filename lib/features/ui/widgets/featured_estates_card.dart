import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/app_styles.dart';

class FeaturedEstatesCard extends StatelessWidget {
  const FeaturedEstatesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.apartmentDetailsRoute),

      child: SizedBox(
        height: 150.h,
        child: Container(
          width: 270.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Image.asset(AppAssets.image,
                  width: 120.w, fit: BoxFit.fill),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AutoSizeText(
                      "Sky Dandelions Apartment",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bold12Primary,
                    ),
                    Row(
                      children: [
                        Image.asset(AppAssets.star,
                            width: 14.w),
                        SizedBox(width: 4.w),
                        Text("4.9",
                            style:
                            AppStyles.bold12Primary),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                            AppAssets.locationIcon,
                            width: 14.w),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "Jakarta, Indonesia",
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: AppStyles
                                .medium10blueDarkColor,
                          ),
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "EG 290/",
                            style: AppStyles
                                .bold18PrimaryColor,
                          ),
                          TextSpan(
                            text: "month",
                            style:
                            AppStyles.bold8Primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
