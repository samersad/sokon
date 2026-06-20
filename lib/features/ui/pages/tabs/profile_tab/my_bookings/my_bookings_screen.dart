import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/supabase_utils.dart';

import '../../../../widgets/back_container.dart';
import 'cubit/my_bookings_states.dart';
import 'cubit/my_bookings_view_model.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final MyBookingsViewModel viewModel = getIt<MyBookingsViewModel>();
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final user = context.read<UserViewModel>().user;
      if (user != null) {
        viewModel.getMyBookings(user.id);
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userViewModel = context.read<UserViewModel>();
    final user = userViewModel.user;

    return BlocBuilder<MyBookingsViewModel, MyBookingsStates>(
      bloc: viewModel,
      builder: (context, state) {
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
                  Text("My Bookings", style: theme.textTheme.headlineMedium),
                  SizedBox(height: 5.h),
                  Text("Track your apartment bookings",
                      style: theme.textTheme.bodyMedium),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: user == null
                        ? const Center(
                            child: Text("Please login to see your bookings"))
                        : Builder(
                            builder: (context) {
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
                                    return buildBookingCard(context, booking);
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            }
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBookingCard(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
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
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: theme.highlightColor, size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.apartmentAddress ?? "No address",
                            style: theme.textTheme.bodyMedium,
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
                  getStatusLabel(booking.status),
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
                  Text("Period", style: theme.textTheme.bodyMedium),
                  Text(
                    "${booking.startDate != null ? dateFormat.format(booking.startDate!) : '-'} - ${booking.endDate != null ? dateFormat.format(booking.endDate!) : '-'}",
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Price", style: theme.textTheme.bodyMedium),
                  Text(
                    "${booking.totalPrice ?? 0} EG",
                    style: theme.textTheme.displaySmall,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "Owner: ${booking.ownerName ?? 'N/A'}",
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 6.h),
          Text(
            "People: ${booking.peopleCount ?? 1}",
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 12.h),
          if (_canCancel(booking))
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelBooking(booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text("Cancel Booking"),
              ),
            ),
        ],
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (normalizeStatus(status)) {
      case 'accepted':
        return Colors.green;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String getStatusLabel(String? status) {
    switch (normalizeStatus(status)) {
      case 'accepted':
      case 'confirmed':
        return 'ACCEPTED';
      case 'cancelled':
      case 'rejected':
        return 'CANCELLED';
      case 'pending':
      default:
        return 'PENDING';
    }
  }

  String normalizeStatus(String? status) {
    final normalized = status?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return 'pending';
    }
    return normalized;
  }

  bool _canCancel(Booking booking) {
    final status = normalizeStatus(booking.status);
    return status == 'pending' || status == 'accepted' || status == 'confirmed';
  }

  Future<void> _cancelBooking(Booking booking) async {
    if (booking.id == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking'),
        content: const Text('Do you want to cancel this booking request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final user = context.read<UserViewModel>().user;
    try {
      await SupabaseUtils.updateBookingStatus(
        booking: booking,
        status: 'cancelled',
        changedByName: user?.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel booking: $e')),
      );
    }
  }
}
