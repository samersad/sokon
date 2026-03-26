import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/features/ui/pages/featured_estates_screen/cubit/featured_estates_states.dart';
import 'package:sokon/features/ui/pages/featured_estates_screen/cubit/featured_estates_view_model.dart';
import 'package:sokon/core/utils/app_colors.dart';

import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';
import '../../widgets/featured_estates_card.dart';

class FeaturedEstateScreen extends StatefulWidget {
  const FeaturedEstateScreen({super.key});

  @override
  State<FeaturedEstateScreen> createState() => _FeaturedEstateScreenState();
}

class _FeaturedEstateScreenState extends State<FeaturedEstateScreen> {
  final FeaturedEstateViewModel viewModel = getIt<FeaturedEstateViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.getFeaturedEstates();
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
                  Text("Featured Estates", style: AppStyles.bold24Primary),
                  SizedBox(height: 5.h),
                  Text("Find the best recommendations place to live",
                      style: AppStyles.medium13GrayWithOpacity),
                  SizedBox(height: 10.h),
                  BlocBuilder<FeaturedEstateViewModel, FeaturedEstateStates>(
                    builder: (context, state) {
                      if (state is FeaturedEstateLoading) {
                        return SizedBox(
                          height: 400.h,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is FeaturedEstateError) {
                        return Center(child: Text(state.message));
                      } else if (state is FeaturedEstateSuccess) {
                        if (state.apartments.isEmpty) {
                          return const Center(child: Text("No featured apartments found"));
                        }
                        return SizedBox(
                          height: 859.h,
                          child: ListView.separated(
                            itemCount: state.apartments.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              return FeaturedEstatesCard(
                                apartment: state.apartments[index],
                              );
                            },
                          ),
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
