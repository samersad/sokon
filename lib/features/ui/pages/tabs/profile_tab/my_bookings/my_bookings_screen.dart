import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../widgets/back_container.dart';
import 'cubit/my_bookings_states.dart';
import 'cubit/my_bookings_view_model.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;

    return BlocProvider(
      create: (context) {
        var viewModel = MyBookingsViewModel();
        if (user != null) {
          viewModel.getMyBookings(user.id!);
        }
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BackContainer(),
                SizedBox(height: 20.h),
                Text("My Bookings", style: AppStyles.bold24Primary),
                SizedBox(height: 5.h),
                Text("Track your apartment bookings",
                    style: AppStyles.medium13GrayWithOpacity),
                SizedBox(height: 20.h),
                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text("Please login to see your bookings"))
                      : BlocBuilder<MyBookingsViewModel, MyBookingsStates>(
                          builder: (context, state) {
                            if (state is MyBookingsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is MyBookingsError) {
                              return Center(
                                  child: Text("Error: ${state.message}"));
                            }
                            if (state is MyBookingsSuccess) {
                              if (state.bookings.isEmpty) {
                                return const Center(
                                    child: Text("No bookings found"));
                              }
                              return ListView.separated(
                                itemCount: state.bookings.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 15.h),
                                itemBuilder: (context, index) {
                                  var booking = state.bookings[index];
                                  return buildBookingCard(booking);
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

  Widget buildBookingCard(Booking booking) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.grayColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: (booking.apartmentImage != null &&
                        booking.apartmentImage!.isNotEmpty)
                    ? Image.network(
                        booking.apartmentImage!,
                        width: 70.w,
                        height: 70.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(AppAssets.imageS,
                                width: 70.w, height: 70.h),
                      )
                    : Image.asset(AppAssets.imageS, width: 70.w, height: 70.h),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.apartmentName ?? "Apartment",
                      style: AppStyles.bold16PrimaryColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: AppColors.grayColor, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.apartmentAddress ?? "No address",
                            style: AppStyles.medium12gray,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  booking.status?.toUpperCase() ?? "PENDING",
                  style: TextStyle(
                    color: getStatusColor(booking.status),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Period", style: AppStyles.regular12gray),
                  Text(
                    "${booking.startDate != null ? dateFormat.format(booking.startDate!) : '-'} - ${booking.endDate != null ? dateFormat.format(booking.endDate!) : '-'}",
                    style: AppStyles.bold12PrimaryColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Price", style: AppStyles.regular12gray),
                  Text(
                    "${booking.totalPrice ?? 0} EG",
                    style: AppStyles.bold14Primary,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "Owner: ${booking.ownerName ?? 'N/A'}",
            style: AppStyles.medium12gray,
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
