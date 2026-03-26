import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_states.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../widgets/back_container.dart';
import '../../../../widgets/nearby_estate_card.dart';


class MyApartmentsScreen extends StatefulWidget {
  const MyApartmentsScreen({super.key});

  @override
  State<MyApartmentsScreen> createState() => _MyApartmentsScreenState();
}

class _MyApartmentsScreenState extends State<MyApartmentsScreen> {
  final ApartmentViewModel viewModel = getIt<ApartmentViewModel>();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    if (user != null) {
      viewModel.getAllApartmentForOwner(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BackContainer(),
                SizedBox(height: 20.h),
                Text("My Apartments", style: AppStyles.bold24Primary),
                SizedBox(height: 5.h),
                Text("Manage your listed apartments",
                    style: AppStyles.medium13GrayWithOpacity),
                SizedBox(height: 20.h),
                Expanded(
                  child: BlocBuilder<ApartmentViewModel, ApartmentState>(
                    builder: (context, state) {
                      if (state is ApartmentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ApartmentError) {
                        return Center(child: Text(state.message));
                      } else if (state is ApartmentLoaded) {
                        if (state.apartments.isEmpty) {
                          return const Center(child: Text("No apartments found."));
                        }
                        return GridView.builder(
                          itemCount: state.apartments.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 0.65,
                          ),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                NearbyEstateCard(
                                  apartment: state.apartments[index],
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 15,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, size: 15, color: Colors.blue),
                                          onPressed: () {
                                            // TODO: Navigate to Edit Screen
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 15,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, size: 15, color: Colors.red),
                                          onPressed: () {
                                            // TODO: Implement Delete Logic
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
