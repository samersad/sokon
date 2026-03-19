import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/apartment_list_provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<ApartmentListProvider>(context, listen: false)
            .getAllApartmentForOwner(user.id);
      }
    });
  }

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
              const BackContainer(),
              SizedBox(height: 20.h),
              Text("My Apartments", style: AppStyles.bold24Primary),
              SizedBox(height: 5.h),
              Text("Manage your listed apartments",
                  style: AppStyles.medium13GrayWithOpacity),
              SizedBox(height: 20.h),
              Expanded(
                child: Consumer<ApartmentListProvider>(
                  builder: (context, provider, child) {
                    if (provider.apartmentList.isEmpty) {
                      return const Center(child: Text("No apartments found."));
                    }
                    return GridView.builder(
                      itemCount: provider.apartmentList.length,
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
                              apartment: provider.apartmentList[index],
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
