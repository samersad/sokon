import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_colors.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';
import '../../widgets/featured_estates_card.dart';

class FeaturedEstateScreen extends StatelessWidget {
  const FeaturedEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackContainer(),
                SizedBox(height: 20.h,),
                Text("Featured Estates",
                    style: AppStyles.bold24Primary),
                SizedBox(height: 5.h,),
                Text("Find the best recommendations place to live",
                    style: AppStyles.medium13GrayWithOpacity),
                SizedBox(height: 10.h,),
                SizedBox(
                  height: 859.h,
                  child: ListView.separated(
                      itemBuilder:(context, index) {
                        return FeaturedEstatesCard();
                      }
                      , separatorBuilder: (context, index) => SizedBox(height: 10.h,)
                      , itemCount: 12)
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
