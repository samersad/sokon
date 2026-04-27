import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';
import 'package:sokon/supabase_utils.dart';

import '../../../../widgets/back_container.dart';
import 'cubit/owner_booking_requests_states.dart';
import 'cubit/owner_booking_requests_view_model.dart';

class OwnerBookingRequestsScreen extends StatefulWidget {
  const OwnerBookingRequestsScreen({super.key});

  @override
  State<OwnerBookingRequestsScreen> createState() =>
      _OwnerBookingRequestsScreenState();
}

class _OwnerBookingRequestsScreenState
    extends State<OwnerBookingRequestsScreen> {
  final OwnerBookingRequestsViewModel viewModel =
      OwnerBookingRequestsViewModel();
  bool isInitialized = false;
  String? _updatingBookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final user = context.read<UserViewModel>().user;
      if (user != null) {
        viewModel.getOwnerBookings(user.id);
      }
      isInitialized = true;
    }
  }

  @override
  void dispose() {
    viewModel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserViewModel>().user;

    return BlocBuilder<OwnerBookingRequestsViewModel,
        OwnerBookingRequestsStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Row(
                    children: [
                      const BackContainer(),
                      SizedBox(width: 15.w),
                      Text("Booking Requests", style: AppStyles.bold20black),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    "Review live booking activity for your apartments",
                    style: AppStyles.medium13GrayWithOpacity,
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text(
                            "Please login to manage your booking requests",
                          ),
                        )
                      : _buildContent(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(OwnerBookingRequestsStates state) {
    if (state is OwnerBookingRequestsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (state is OwnerBookingRequestsError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 12.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: AppStyles.medium13Gray,
              ),
            ],
          ),
        ),
      );
    }

    if (state is OwnerBookingRequestsSuccess) {
      if (state.bookings.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: state.bookings.length,
        separatorBuilder: (context, index) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          final booking = state.bookings[index];
          return _buildBookingCard(booking);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBookingCard(Booking booking) {
    final periodFormat = DateFormat('dd MMM yyyy');
    final createdAtFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final status = _normalizeStatus(booking.status);
    final isUpdating = _updatingBookingId == booking.id;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: (booking.apartmentImage != null &&
                        booking.apartmentImage!.isNotEmpty)
                    ? Image.network(
                        booking.apartmentImage!,
                        width: 78.w,
                        height: 78.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          AppAssets.imageS,
                          width: 78.w,
                          height: 78.h,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        AppAssets.imageS,
                        width: 78.w,
                        height: 78.h,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: 14.w),
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
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: AppColors.grayColor,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.apartmentAddress ?? "No address",
                            style: AppStyles.medium12gray,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Client: ${booking.clientName ?? 'N/A'}",
                      style: AppStyles.bold12PrimaryColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  label: "Period",
                  value:
                      "${booking.startDate != null ? periodFormat.format(booking.startDate!) : '-'} - ${booking.endDate != null ? periodFormat.format(booking.endDate!) : '-'}",
                ),
                SizedBox(height: 10.h),
                _buildInfoRow(
                  label: "Total Price",
                  value:
                      "${booking.totalPrice?.toStringAsFixed(0) ?? '0'} EG",
                ),
                SizedBox(height: 10.h),
                _buildInfoRow(
                  label: "Requested",
                  value: booking.createdAt != null
                      ? createdAtFormat.format(booking.createdAt!)
                      : "Unknown",
                ),
              ],
            ),
          ),
          if (isUpdating) ...[
            SizedBox(height: 12.h),
            const LinearProgressIndicator(
              minHeight: 3,
              color: AppColors.primaryColor,
            ),
          ],
          if (_shouldShowActions(status)) ...[
            SizedBox(height: 14.h),
            _buildActions(booking, status, isUpdating),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.regular12gray),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppStyles.bold12PrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Booking booking, String status, bool isUpdating) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () => _updateBookingStatus(
                        booking: booking,
                        nextStatus: 'accepted',
                        dialogTitle: 'Accept booking',
                        dialogMessage:
                            'Do you want to accept this booking request?',
                        successMessage: 'Booking accepted',
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text("Accept"),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: isUpdating
                  ? null
                  : () => _updateBookingStatus(
                        booking: booking,
                        nextStatus: 'rejected',
                        dialogTitle: 'Reject booking',
                        dialogMessage:
                            'Do you want to reject this booking request?',
                        successMessage: 'Booking rejected',
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withOpacity(0.35)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text("Reject"),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isUpdating
            ? null
            : () => _updateBookingStatus(
                  booking: booking,
                  nextStatus: 'cancelled',
                  dialogTitle: 'Cancel booking',
                  dialogMessage: 'Do you want to cancel this booking?',
                  successMessage: 'Booking cancelled',
                ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.35)),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: const Text("Cancel Booking"),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(26.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60.sp,
                color: AppColors.primaryColor.withOpacity(0.22),
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              "No booking requests yet",
              style: AppStyles.bold18PrimaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              "New booking activity for your apartments will appear here in real time.",
              textAlign: TextAlign.center,
              style: AppStyles.medium12gray,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus({
    required Booking booking,
    required String nextStatus,
    required String dialogTitle,
    required String dialogMessage,
    required String successMessage,
  }) async {
    if (booking.id == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogMessage),
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

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _updatingBookingId = booking.id;
    });

    final user = context.read<UserViewModel>().user;

    try {
      await SupabaseUtils.updateBookingStatus(
        booking: booking,
        status: nextStatus,
        changedByName: user?.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingBookingId = null;
        });
      }
    }
  }

  bool _shouldShowActions(String status) {
    return status == 'pending' || status == 'accepted' || status == 'confirmed';
  }

  String _normalizeStatus(String? status) {
    final normalized = status?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return 'pending';
    }
    return normalized;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.deepOrange;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'accepted':
      case 'confirmed':
        return 'ACCEPTED';
      case 'cancelled':
        return 'CANCELLED';
      case 'rejected':
        return 'REJECTED';
      case 'pending':
      default:
        return 'PENDING';
    }
  }
}
