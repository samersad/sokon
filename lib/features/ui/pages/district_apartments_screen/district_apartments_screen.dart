import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/model/district_summary.dart';

import '../../widgets/back_container.dart';
import '../../widgets/featured_estates_card.dart';

class DistrictApartmentsScreen extends StatelessWidget {
  const DistrictApartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final districtSummary = ModalRoute.of(context)!.settings.arguments as DistrictSummary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackContainer(),
              SizedBox(height: 20.h),
              Text(districtSummary.district, style: theme.textTheme.headlineMedium),
              SizedBox(height: 5.h),
              Text(
                "${districtSummary.apartmentCount} apartments in this district",
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: districtSummary.apartments.isEmpty
                    ? const Center(child: Text("No apartments found in this district"))
                    : ListView.separated(
                        itemCount: districtSummary.apartments.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          return FeaturedEstatesCard(
                            apartment: districtSummary.apartments[index],
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
