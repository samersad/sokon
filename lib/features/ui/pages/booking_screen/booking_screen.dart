import 'package:auto_size_text/auto_size_text.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/features/ui/pages/booking_screen/cubit/booking_states.dart';
import 'package:sokon/features/ui/pages/booking_screen/cubit/booking_view_model.dart';
import 'package:sokon/features/ui/widgets/alert_dialog_utils.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/custom_elevated_buttom.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingViewModel viewModel = getIt<BookingViewModel>();
  late ApartmentResponse apartment;
  bool isInitialized = false;
  bool isLoadingShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      apartment = ModalRoute.of(context)!.settings.arguments as ApartmentResponse;
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return BlocListener<BookingViewModel, BookingStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state.status == BookingStatus.loading) {
          isLoadingShown = true;
          AlertDialogUtils.showLoading(context: context, msg: l10n.processing);
        } else if (state.status == BookingStatus.error) {
          if (isLoadingShown) {
            AlertDialogUtils.hideLoading(context: context);
            isLoadingShown = false;
          }

          if (state.errorMessage == l10n.selectDateRange) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.somethingWentWrong),
            ),
          );
        } else if (state.status == BookingStatus.success) {
          if (isLoadingShown) {
            AlertDialogUtils.hideLoading(context: context);
            isLoadingShown = false;
          }
          showSuccessDialog(context);
        }
      },
      child: BlocBuilder<BookingViewModel, BookingStates>(
        bloc: viewModel,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              title: Text(l10n.booking, style: theme.textTheme.titleLarge),
              centerTitle: true,
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(minHeight: 110.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.sp),
                          border: Border.all(
                            color: theme.highlightColor,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child:
                                    (apartment.images != null &&
                                        apartment.images!.isNotEmpty)
                                    ? Image.network(
                                        apartment.images![0],
                                        width: 80.w,
                                        height: 80.h,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        AppAssets.imageS,
                                        width: 80.w,
                                        height: 80.h,
                                      ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      apartment.name ?? "Apartment",
                                      style: theme.textTheme.labelMedium,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Image.asset(
                                          AppAssets.locationIcon,
                                          width: 14.w,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: AutoSizeText(
                                            apartment.address ?? l10n.noAddress,
                                            style: theme.textTheme.bodyMedium,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Text(
                                          "${apartment.price ?? 0}/month",
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const Spacer(),
                                        Image.asset(
                                          AppAssets.star,
                                          width: 14.w,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          apartment.ratingLabel,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(l10n.period, style: theme.textTheme.headlineSmall),

                      InkWell(
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          viewModel.selectDateRange(picked);
                        },
                        child: Row(
                          children: [
                            Image.asset(AppAssets.dateIcon),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.date, style: theme.textTheme.bodyMedium),
                                Text(
                                  viewModel.getFormattedDate(),
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (state.showDateError) ...[
                        SizedBox(height: 8.h),
                        Text(
                          "Select date",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.redMaterial,
                          ),
                        ),
                      ],

                      SizedBox(height: 10.h),
                      Divider(color: theme.dividerColor),

                      SizedBox(height: 10.h),

                      _buildPeopleSelector(theme),

                      SizedBox(height: 16.h),

                      Text(
                        l10n.checkDateBeforePayment,
                        style: theme.textTheme.bodyMedium,
                      ),

                      SizedBox(height: 20.h),

                      Text(l10n.payments, style: theme.textTheme.headlineSmall),

                      Row(
                        children: [
                          if (state.cardNumber != null)
                            Image.asset(AppAssets.mastercardIcon),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              state.cardNumber == null
                                  ? l10n.noCardAdded
                                  : "**** **** **** ${state.cardNumber!.substring(state.cardNumber!.length - 4)}",
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.addCardRoute);
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                viewModel.updateCardData(result);
                              }
                            },
                            child: Text(
                              state.cardNumber == null ? l10n.addCard : l10n.edit,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),

                      Divider(color: AppColors.grayColor),

                      TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.enterVoucher,
                          style: theme.textTheme.labelMedium?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        l10n.priceDetails,
                        style: theme.textTheme.headlineSmall,
                      ),

                      buildRow(
                        context,
                        l10n.periodTime,
                        state.selectedDate == null
                            ? "-"
                            : "${state.selectedDate!.duration.inDays} Days",
                      ),
                      buildRow(
                        context,
                        l10n.peopleRenting,
                        "${state.peopleCount} / ${apartment.availablePeople ?? apartment.maxPeople ?? 1}",
                      ),
                      buildRow(
                        context,
                        l10n.monthlyPayment,
                        "${apartment.price ?? 0} EG",
                      ),
                      buildRow(context, l10n.tax, "10 EG"),
                      buildRow(
                        context,
                        l10n.total,
                        "${(apartment.price ?? 0) + 10} EG",
                        isTotal: true,
                      ),

                      SizedBox(height: 40.h),

                      CustomElevatedButtom(
                        onPressed: () => viewModel.confirmBooking(apartment),
                        text: l10n.confirmAndPay,
                        customPadding: 20,
                        borderRadius: 10.r,
                        backgroundColorElevated: theme.primaryColor,
                        textStyle: AppStyles.semiBold20White,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(
    BuildContext context,
    String t1,
    String t2, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            t1,
            style: isTotal
                ? theme.textTheme.labelMedium
                : theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            t2,
            style: isTotal
                ? theme.textTheme.titleMedium
                : theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final availablePeople =
        apartment.availablePeople ?? apartment.maxPeople ?? 1;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.addApartmentDarkGradientStart,
                  AppColors.addApartmentDarkGradientEnd,
                ]
              : [
                  AppColors.bookingLightGradientStart,
                  AppColors.bookingLightGradientEnd,
                ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: isDark ? 0.35 : 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: theme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.people, style: theme.textTheme.labelMedium),
                SizedBox(height: 4.h),
                Text(
                  "$availablePeople ${availablePeople == 1 ? 'spot' : 'spots'} currently available",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: viewModel.state.peopleCount > 1
                ? () => viewModel.updatePeopleCount(
                    viewModel.state.peopleCount - 1,
                  )
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: theme.highlightColor,
          ),
          Text(
            "${viewModel.state.peopleCount}",
            style: theme.textTheme.labelMedium,
          ),
          IconButton(
            onPressed: viewModel.state.peopleCount < availablePeople
                ? () => viewModel.updatePeopleCount(
                    viewModel.state.peopleCount + 1,
                  )
                : null,
            icon: const Icon(Icons.add_circle),
            color: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    final l10n = AppLocalizations.of(parentContext)!;
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.successBg),
                  const SizedBox(height: 20),
                  Text(
                    l10n.bookingSuccessTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.bookingSuccessSub,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 25),
                  CustomElevatedButtom(
                    onPressed: () {
                      Navigator.of(parentContext).pushNamedAndRemoveUntil(
                        AppRoutes.homeScreenRoute,
                        (route) => false,
                      );
                    },
                    text: "successfully",
                    customPadding: 15,
                    borderRadius: 10.r,
                    backgroundColorElevated: theme.primaryColor,
                    textStyle: AppStyles.semiBold20White,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
