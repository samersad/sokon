import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/BookingResponse.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

import '../../../../../../core/utils/app_routes.dart';
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
  String _selectedStatusFilter = 'all';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final user = context.read<UserViewModel>().user;
      final userId = user?.id;
      if (userId != null && userId.isNotEmpty) {
        viewModel.getOwnerBookings(userId);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = context.read<UserViewModel>().user;

    return BlocBuilder<OwnerBookingRequestsViewModel,
        OwnerBookingRequestsStates>(
      bloc: viewModel,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                      Text(l10n.bookingRequests, style: theme.textTheme.headlineMedium),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    l10n.reviewLiveBookingActivity,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: user == null
                      ? Center(
                          child: Text(
                            l10n.pleaseLoginToManageRequests,
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (state is OwnerBookingRequestsLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
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
                style: theme.textTheme.bodyMedium,
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

      final filteredBookings = state.bookings
          .where((booking) => _matchesStatusFilter(booking.status))
          .toList();

      return Column(
        children: [
          _buildStatusFilterBar(state.bookings),
          Expanded(
            child: filteredBookings.isEmpty
                ? _buildFilteredEmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (context, index) => SizedBox(height: 15.h),
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusFilterBar(List<BookingResponse> bookings) {
    final filters = ['all', 'pending', 'confirmed', 'rejected', 'cancelled'];
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final count = filter == 'all'
              ? bookings.length
              : bookings
                  .where((booking) => _statusBucket(booking.status) == filter)
                  .length;
          return _StatusFilterChip(
            label: _getFilterLabel(filter),
            count: count,
            color: _getFilterColor(filter),
            selected: _selectedStatusFilter == filter,
            onTap: () => setState(() => _selectedStatusFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingResponse booking) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final periodFormat = DateFormat('dd MMM yyyy');
    final createdAtFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final status = _normalizeStatus(booking.status);
    final statusBucket = _statusBucket(booking.status);
    final isUpdating = _updatingBookingId == booking.id;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.2)
            : theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                      style: theme.textTheme.labelMedium,
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
                          color: theme.highlightColor,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.apartmentAddress ?? "No address",
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Client: ${booking.clientName ?? 'N/A'}",
                      style: theme.textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(statusBucket).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    color: _getStatusColor(statusBucket),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (statusBucket == 'confirmed') ...[
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
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: theme.disabledColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  label: l10n.period,
                  value:
                      "${booking.startDate != null ? periodFormat.format(booking.startDate!) : '-'} - ${booking.endDate != null ? periodFormat.format(booking.endDate!) : '-'}",
                ),
                SizedBox(height: 10.h),
                _buildInfoRow(
                  label: l10n.totalPrice,
                  value:
                      "${booking.totalPrice?.toStringAsFixed(0) ?? '0'} EG",
                ),
                SizedBox(height: 10.h),
                _buildInfoRow(
                  label: l10n.people,
                  value: "${booking.peopleCount ?? 1}",
                ),
                SizedBox(height: 10.h),
                _buildInfoRow(
                  label: "Requested",
                  value: booking.createdAt != null
                      ? createdAtFormat.format(booking.createdAt!.toLocal())
                      : l10n.unknown,
                ),
              ],
            ),
          ),
          if (isUpdating) ...[
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              minHeight: 3,
              color: theme.primaryColor,
            ),
          ],
          if (_shouldShowActions(statusBucket)) ...[
            SizedBox(height: 14.h),
            _buildActions(booking, statusBucket, isUpdating),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.displaySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BookingResponse booking, String status, bool isUpdating) {
   var theme=Theme.of(context);
   final l10n = AppLocalizations.of(context)!;
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
                        dialogTitle: l10n.acceptBooking,
                        dialogMessage:
                            l10n.confirmAcceptBooking,
                        successMessage: l10n.bookingAccepted,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(l10n.accept,style: theme.textTheme.bodySmall,),
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
                        dialogTitle: l10n.rejectBooking,
                        dialogMessage:
                            l10n.confirmRejectBooking,
                        successMessage: l10n.bookingRejected,
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withValues(alpha: 0.35)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child:  Text(l10n.reject),
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
                  dialogMessage: l10n.confirmCancelBooking,
                  successMessage: l10n.bookingCancelled,
                ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withValues(alpha: 0.35)),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child:  Text(l10n.cancelBooking),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(26.r),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60.sp,
                color: theme.primaryColor.withValues(alpha: 0.22),
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              l10n.noBookingRequestsYet,
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.newBookingActivity,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 52.sp,
              color: theme.primaryColor.withValues(alpha: 0.35),
            ),
            SizedBox(height: 16.h),
            Text(
              'No ${_getFilterLabel(_selectedStatusFilter).toLowerCase()} requests',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose another status to review more booking requests.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus({
    required BookingResponse booking,
    required String nextStatus,
    required String dialogTitle,
    required String dialogMessage,
    required String successMessage,
  }) async {
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
        title: Text(dialogTitle),
        content: Text(dialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:  Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _updatingBookingId = bookingId;
    });

    try {
      await viewModel.updateBookingStatus(
        bookingId: bookingId,
        status: nextStatus,
      );
      if (!mounted) return;
      final userViewModel = context.read<UserViewModel>();
      final userId = userViewModel.user?.id;
      if (userId != null && userId.isNotEmpty) {
        await viewModel.getOwnerBookings(userId);
      }
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
    return status == 'pending' || status == 'confirmed';
  }

  void _openChat(BookingResponse booking) {
    if (booking.clientId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.chatRoute,
        arguments: {
          'receiverId': booking.clientId,
          'receiverName': booking.clientName ?? 'Client',
          'receiverPhotoUrl': null,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client contact not available')),
      );
    }
  }

  String _normalizeStatus(String? status) {
    final normalized = status?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return 'pending';
    }
    return normalized;
  }

  String _statusBucket(String? status) {
    final normalized = _normalizeStatus(status);
    if (normalized == 'accepted' || normalized == 'confirmed') {
      return 'confirmed';
    }
    if (normalized == 'rejected') {
      return 'rejected';
    }
    if (normalized == 'cancelled' || normalized == 'canceled') {
      return 'cancelled';
    }
    return 'pending';
  }

  bool _matchesStatusFilter(String? status) {
    if (_selectedStatusFilter == 'all') {
      return true;
    }
    return _statusBucket(status) == _selectedStatusFilter;
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  Color _getFilterColor(String filter) {
    if (filter == 'all') {
      return Theme.of(context).primaryColor;
    }
    return _getStatusColor(filter);
  }

  String _getStatusLabel(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'accepted':
      case 'confirmed':
        return l10n.localeName == 'ar' ? 'مؤكد' : 'CONFIRMED';
      case 'cancelled':
        return l10n.cancelledStatus;
      case 'rejected':
        return l10n.localeName == 'ar' ? 'مرفوض' : 'REJECTED';
      case 'pending':
      default:
        return l10n.pendingStatus;
    }
  }

  String _getFilterLabel(String filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case 'pending':
        return l10n.localeName == 'ar' ? 'معلق' : 'Pending';
      case 'confirmed':
        return l10n.localeName == 'ar' ? 'مؤكد' : 'Confirmed';
      case 'rejected':
        return l10n.localeName == 'ar' ? 'مرفوض' : 'Rejected';
      case 'cancelled':
        return l10n.localeName == 'ar' ? 'ملغى' : 'Cancelled';
      case 'all':
      default:
        return l10n.localeName == 'ar' ? 'الكل' : 'All';
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? color
                : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.16),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? color : theme.highlightColor,
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              constraints: BoxConstraints(minWidth: 24.w),
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: selected
                    ? color
                    : theme.disabledColor.withValues(alpha: isDark ? 0.7 : 1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected ? Colors.white : theme.highlightColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
