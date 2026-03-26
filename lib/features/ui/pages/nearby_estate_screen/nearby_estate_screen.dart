import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/features/ui/pages/nearby_estate_screen/cubit/nearby_estate_states.dart';
import 'package:sokon/features/ui/pages/nearby_estate_screen/cubit/nearby_estate_view_model.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';
import '../../widgets/nearby_estate_card.dart';

class NearbyEstateScreen extends StatefulWidget {
  const NearbyEstateScreen({super.key});

  @override
  State<NearbyEstateScreen> createState() => _NearbyEstateScreenState();
}

class _NearbyEstateScreenState extends State<NearbyEstateScreen> {
  final NearbyEstateViewModel viewModel = getIt<NearbyEstateViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.getNearbyEstates();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackContainer(),
                  SizedBox(height: 20.h),
                  Text("Nearby Estate", style: AppStyles.bold24Primary),
                  SizedBox(height: 5.h),
                  Text("Find the best recommendations place to live",
                      style: AppStyles.medium13GrayWithOpacity),
                  SizedBox(height: 10.h),
                  BlocBuilder<NearbyEstateViewModel, NearbyEstateStates>(
                    builder: (context, state) {
                      if (state is NearbyEstateLoading) {
                        return SizedBox(
                          height: 400.h,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is NearbyEstateError) {
                        return Center(child: Text(state.message));
                      } else if (state is NearbyEstateSuccess) {
                        if (state.apartments.isEmpty) {
                          return const Center(child: Text("No apartments found"));
                        }
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2.w,
                              mainAxisSpacing: 5.h,
                              childAspectRatio: 0.6),
                          shrinkWrap: true,
                          itemCount: state.apartments.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: NearbyEstateCard(
                                apartment: state.apartments[index],
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
