import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/apartment.dart';
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
  late Apartment apartment;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      apartment = ModalRoute.of(context)!.settings.arguments as Apartment;
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingViewModel, BookingStates>(
      bloc: viewModel,
      listener: (context, state) {
        if (state is BookingLoading) {
          AlertDialogUtils.showLoading(context: context, msg: "Processing...");
        } else if (state is BookingError) {
          AlertDialogUtils.hideLoading(context: context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is BookingSuccess) {
          AlertDialogUtils.hideLoading(context: context);
          showSuccessDialog(context);
        }
      },
      child: BlocBuilder<BookingViewModel, BookingStates>(
        bloc: viewModel,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              elevation: 0,
              title: Text("Booking", style: AppStyles.bold20blackIner),
              centerTitle: true,
            ),
            backgroundColor: AppColors.whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(minHeight: 110.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.sp),
                          border: Border.all(color: AppColors.grayColor, width: 2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: (apartment.images != null &&
                                    apartment.images!.isNotEmpty)
                                    ? Image.network(
                                  apartment.images![0],
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(AppAssets.imageS,
                                    width: 80.w, height: 80.h),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      apartment.name ?? "Apartment",
                                      style: AppStyles.semiBold14DarkPrimary,
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Image.asset(AppAssets.locationIcon,
                                            width: 14.w),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: AutoSizeText(
                                            apartment.address ?? "No Address",
                                            style: AppStyles.medium12gray,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: [
                                        Text("${apartment.price ?? 0}/month",
                                            style: AppStyles.regular14black),
                                        const Spacer(),
                                        Image.asset(AppAssets.star, width: 14.w),
                                        SizedBox(width: 4.w),
                                        Text("4.8", style: AppStyles.regular14black),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text("Period", style: AppStyles.bold20black),

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
                                Text("Date", style: AppStyles.regular14gray),
                                Text(viewModel.getFormattedDate(),
                                    style: AppStyles.medium16black),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),
                      Divider(color: AppColors.grayColor),

                      SizedBox(height: 10.h),

                      Text(
                        "Make sure to check your date before making any sort of payments",
                        style: AppStyles.regular14gray,
                      ),

                      SizedBox(height: 20.h),

                      Text("Payments", style: AppStyles.bold20black),

                      Row(
                        children: [
                          if (viewModel.cardNumber != null)
                            Image.asset(AppAssets.mastercardIcon),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              viewModel.cardNumber == null
                                  ? "No Card Added"
                                  : "**** **** **** ${viewModel.cardNumber!.substring(viewModel.cardNumber!.length - 4)}",
                              style: AppStyles.bold20black,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).pushNamed(
                                AppRoutes.addCardRoute,
                              );
                              if (result != null && result is Map<String, dynamic>) {
                                viewModel.updateCardData(result);
                              }
                            },
                            child: Text(
                              viewModel.cardNumber == null ? "Add Card" : "Edit",
                              style: AppStyles.bold20black,
                            ),
                          ),
                        ],
                      ),

                      Divider(color: AppColors.grayColor),

                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Enter a Voucher",
                          style: AppStyles.bold20black.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Text("Price Details", style: AppStyles.bold20black),

                      buildRow("Period time",
                          viewModel.selectedDate == null ? "-" : "${viewModel.selectedDate!.duration.inDays} Days"),
                      buildRow("Monthly payment", "${apartment.price ?? 0} EG"),
                      buildRow("Tax", "10 EG"),
                      buildRow("Total", "${(apartment.price ?? 0) + 10} EG",
                          isTotal: true),

                      SizedBox(height: 40.h),

                      CustomElevatedButtom(
                        onPressed: () => viewModel.confirmBooking(apartment),
                        text: "Confirm and Pay",
                        customPadding: 20,
                        borderRadius: 10.r,
                        backgroundColorElevated: AppColors.darkBlueColor,
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

  Widget buildRow(String t1, String t2, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            t1,
            style: isTotal ? AppStyles.medium16black : AppStyles.regular14gray,
          ),
          const Spacer(),
          Text(
            t2,
            style: isTotal
                ? AppStyles.bold18PrimaryColor
                : AppStyles.medium16black,
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                    "Yey, your booking success",
                    textAlign: TextAlign.center,
                    style: AppStyles.bold20black,
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "you have successfully booked a property, enjoy your property",
                      textAlign: TextAlign.center,
                      style: AppStyles.regular14gray),
                  const SizedBox(height: 25),
                  CustomElevatedButtom(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    text: "successfully",
                    customPadding: 15,
                    borderRadius: 10.r,
                    backgroundColorElevated: AppColors.darkBlueColor,
                    textStyle: AppStyles.semiBold20White,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
