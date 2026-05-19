import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';

class TopLocationScreen extends StatelessWidget {
  const TopLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackContainer(),
                SizedBox(height: 20.h,),
                Text("Top Location",
                    style: theme.textTheme.headlineMedium),
                SizedBox(height: 5.h,),
                Text("Find the best recommendations place to live",
                    style: theme.textTheme.bodyMedium),
                SizedBox(height: 10.h,),
                SizedBox(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 5.h,
                        childAspectRatio: 0.8
                    )
                      , shrinkWrap: true,
                      itemCount: 12,
                      physics: NeverScrollableScrollPhysics()
                      , itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: theme.disabledColor,
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(child: Image.asset(AppAssets.topImage)),
                                  SizedBox(height: 10.h,),
                                  Text("Malang",
                                      style: theme.textTheme.labelMedium),
                                ],
                              ),
                            )
                          ),
                        );
                      },),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
