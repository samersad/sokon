import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_states.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/district_summary.dart';
import 'package:sokon/core/utils/app_routes.dart';
import '../../widgets/back_container.dart';
import '../../widgets/district_location_card.dart';

class TopLocationScreen extends StatefulWidget {
  const TopLocationScreen({super.key});

  @override
  State<TopLocationScreen> createState() => _TopLocationScreenState();
}

class _TopLocationScreenState extends State<TopLocationScreen> {
  final ApartmentViewModel viewModel = getIt<ApartmentViewModel>();

  @override
  void initState() {
    super.initState();
    if (viewModel.apartmentList.isEmpty) {
      viewModel.getAllApartments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
              Text(l10n.topLocation, style: theme.textTheme.headlineMedium),
              SizedBox(height: 5.h),
              Text(
                l10n.districtsRanked,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocBuilder<ApartmentViewModel, ApartmentState>(
                  bloc: viewModel,
                  builder: (context, state) {
                    final districts = buildDistrictSummaries(viewModel.apartmentList);

                    if (state is ApartmentLoading && districts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ApartmentError && districts.isEmpty) {
                      return Center(child: Text(state.message));
                    }

                    if (districts.isEmpty) {
                      return Center(child: Text(l10n.noDistrictsFound));
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 1.9,
                      ),
                      itemCount: districts.length,
                      itemBuilder: (context, index) {
                        final district = districts[index];
                        return DistrictLocationCard(
                          districtSummary: district,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.districtApartmentsRoute,
                              arguments: district,
                            );
                          },
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
