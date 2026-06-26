import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/BookingResponse.dart';
import 'package:sokon/core/utils/app_assets.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_routes.dart';
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
  String? _ratingBookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final user = context.read<UserViewModel>().user;
      final userId = user?.id;
      if (userId != null && userId.isNotEmpty) {
        viewModel.getMyBookings(userId);
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(l10n.myBookings, style: theme.textTheme.headlineMedium),
                  SizedBox(height: 5.h),
                  Text(
                    l10n.trackYourApartmentBookings,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: user == null
                        ? Center(
                            child: Text(l10n.pleaseLoginToSeeBookings),
                          )
                        : Builder(
                            builder: (context) {
                              if (state is MyBookingsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (state is MyBookingsError) {
                                return Center(
                                  child: Text("Error: ${state.message}"),
                                );
                              }
                              if (state is MyBookingsSuccess) {
                                if (state.bookings.isEmpty) {
                                  return Center(
                                    child: Text(l10n.noBookingsFound),
                                  );
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
                            },
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

  Widget buildBookingCard(BuildContext context, BookingResponse booking) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child:
                    (booking.apartmentImage != null &&
                        booking.apartmentImage!.isNotEmpty)
                    ? Image.network(
                        booking.apartmentImage!,
                        width: 70.w,
                        height: 70.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              AppAssets.imageS,
                              width: 70.w,
                              height: 70.h,
                            ),
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
                        Icon(
                          Icons.location_on,
                          color: theme.highlightColor,
                          size: 14.sp,
                        ),
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
                  color: getStatusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  getStatusLabel(booking.status, l10n),
                  style: TextStyle(
                    color: getStatusColor(booking.status),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (normalizeStatus(booking.status) == 'accepted' || normalizeStatus(booking.status) == 'confirmed') ...[
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () => _openChat(booking),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.primaryColor,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.period, style: theme.textTheme.bodyMedium),
                  Text(
                    "${booking.startDate != null ? dateFormat.format(booking.startDate!.toLocal()) : '-'} - ${booking.endDate != null ? dateFormat.format(booking.endDate!.toLocal()) : '-'}",
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.totalPrice, style: theme.textTheme.bodyMedium),
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
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(l10n.cancelBooking),
              ),
            ),
          if (_canRate(booking)) ...[
            SizedBox(height: 12.h),
            _buildRatingBox(context, booking, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBox(BuildContext context, BookingResponse booking, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isSaving = _ratingBookingId == booking.id;
    final selectedRating = booking.rating ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.disabledColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            selectedRating > 0 ? l10n.yourRating : l10n.rateYourStay,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = rating <= selectedRating;
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.w),
                onPressed: isSaving
                    ? null
                    : () => _rateBooking(booking, rating),
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isSelected ? const Color(0xFFFFB800) : Colors.grey,
                  size: 30.sp,
                ),
              );
            }),
          ),
          if (isSaving) ...[
            SizedBox(height: 6.h),
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
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

  String getStatusLabel(String? status, AppLocalizations l10n) {
    switch (normalizeStatus(status)) {
      case 'accepted':
      case 'confirmed':
        return l10n.acceptedStatus;
      case 'cancelled':
      case 'rejected':
        return l10n.cancelledStatus;
      case 'pending':
      default:
        return l10n.pendingStatus;
    }
  }

  String normalizeStatus(String? status) {
    final normalized = status?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return 'pending';
    }
    return normalized;
  }

  bool _canCancel(BookingResponse booking) {
    final status = normalizeStatus(booking.status);
    return status == 'pending' || status == 'accepted' || status == 'confirmed';
  }

  bool _canRate(BookingResponse booking) {
    final status = normalizeStatus(booking.status);
    return booking.id != null &&
        (status == 'accepted' || status == 'confirmed');
  }

  void _openChat(BookingResponse booking) {
    if (booking.ownerId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatRoute,
        arguments: {
          'receiverId': booking.ownerId,
          'receiverName': booking.ownerName ?? 'Owner',
          'receiverPhotoUrl': null,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner contact not available')),
      );
    }
  }

  Future<void> _rateBooking(BookingResponse booking, int rating) async {
    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking id is required')),
      );
      return;
    }

    setState(() {
      _ratingBookingId = bookingId;
    });

    try {
      await viewModel.rateBooking(bookingId: bookingId, rating: rating);
      if (!mounted) return;
      setState(() {
        _ratingBookingId = null;
      });
      final userViewModel = context.read<UserViewModel>();
      final userId = userViewModel.user?.id;
      if (userId != null && userId.isNotEmpty) {
        await viewModel.getMyBookings(userId);
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ratingSaved)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ratingBookingId = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save rating: $e')));
    }
  }

  Future<void> _cancelBooking(BookingResponse booking) async {
    final bookingId = booking.id;
    if (bookingId == null || bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking id is required')),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking'),
        content: Text(l10n.confirmCancelBookingRequest),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    try {
      await viewModel.updateBookingStatus(
        bookingId: bookingId,
        status: 'cancelled',
      );
      if (!mounted) return;
      final userViewModel = context.read<UserViewModel>();
      final userId = userViewModel.user?.id;
      if (userId != null && userId.isNotEmpty) {
        await viewModel.getMyBookings(userId);
      }
      if (!mounted) return;
      final l10nAgain = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10nAgain.bookingCancelled)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel booking: $e')));
    }
  }
}
