import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/apartment_list_provider.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';
import '../../widgets/nearby_estate_card.dart';

class NearbyEstateScreen extends StatelessWidget {
  const NearbyEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var apartmentProvider = Provider.of<ApartmentListProvider>(context);

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
                Text("Nearby Estate",
                    style: AppStyles.bold24Primary),
                SizedBox(height: 5.h,),
                Text("Find the best recommendations place to live",
                    style: AppStyles.medium13GrayWithOpacity),
                SizedBox(height: 10.h,),
                SizedBox(
                  child: apartmentProvider.apartmentList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 5.h,
                        childAspectRatio: 0.6
                    )
                    , shrinkWrap: true,
                    itemCount: apartmentProvider.apartmentList.length,
                    physics: const NeverScrollableScrollPhysics()
                    , itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NearbyEstateCard(apartment: apartmentProvider.apartmentList[index],),
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
