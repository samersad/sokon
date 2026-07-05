import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return BlocBuilder<FeaturedEstateViewModel, FeaturedEstateStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackContainer(),
                    SizedBox(height: 20.h),
                    Text(l10n.featuredEstates, style: theme.textTheme.headlineMedium),
                    SizedBox(height: 5.h),
                    Text(l10n.findBestRecommendations,
                        style: theme.textTheme.bodyMedium),
                    SizedBox(height: 10.h),
                    Builder(
                      builder: (context) {
                        if (state is FeaturedEstateLoading) {
                          return SizedBox(
                            height: 400.h,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (state is FeaturedEstateError) {
                          return Center(child: Text(state.message));
                        } else if (state is FeaturedEstateSuccess) {
                          if (state.apartments.isEmpty) {
                            return  Center(child: Text(l10n.noFeaturedApartmentsFound));
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.apartments.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              return FeaturedEstatesCard(
                                apartment: state.apartments[index],
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
