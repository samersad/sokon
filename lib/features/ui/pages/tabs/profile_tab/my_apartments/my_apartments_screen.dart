import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_states.dart';
import 'package:sokon/core/cache/cubit_manger/apartment_view_model.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/model/BookingResponse.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/data/repository/booking/data_sources/remote/impl/booking_remote_data_impl.dart';
import 'package:sokon/data/repository/booking/repository/booking_repository.dart';
import 'package:sokon/data/repository/booking/repository/impl/booking_repository_impl.dart';

import '../../../../../../core/utils/app_routes.dart';
import '../../../../widgets/back_container.dart';

class MyApartmentsScreen extends StatefulWidget {
  const MyApartmentsScreen({super.key});

  @override
  State<MyApartmentsScreen> createState() => _MyApartmentsScreenState();
}

class _MyApartmentsScreenState extends State<MyApartmentsScreen> {
  final BookingRepository _bookingRepository =
      BookingRepositoryImpl(BookingRemoteDataImpl());
  List<BookingResponse> _ownerBookings = [];
  bool _isLoadingBookings = false;
  String? _bookingsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserViewModel>().user;
      final userId = user?.id;
      if (userId != null && userId.isNotEmpty) {
        context.read<ApartmentViewModel>().getAllApartmentForOwner(userId);
        _loadOwnerBookings(userId);
      }
    });
  }

  Future<void> _loadOwnerBookings(String userId) async {
    setState(() {
      _isLoadingBookings = true;
      _bookingsError = null;
    });

    try {
      final bookings = await _bookingRepository.getOwnerBookings(userId);
      if (!mounted) return;
      setState(() {
        _ownerBookings = bookings;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bookingsError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return BlocBuilder<ApartmentViewModel, ApartmentState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  child: Row(
                    children: [
                      const BackContainer(),
                      SizedBox(width: 15.w),
                      Text(
                        l10n.myApartments,
                        style: theme.textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.manageYourProperties,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ApartmentState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (state is ApartmentLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    } else if (state is ApartmentError) {
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
    } else if (state is ApartmentLoaded) {
      if (state.apartments.isEmpty) {
        return _buildEmptyState(context);
      }
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: state.apartments.length,
        separatorBuilder: (context, index) => SizedBox(height: 18.h),
        itemBuilder: (context, index) {
          final apartment = state.apartments[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child:
                            apartment.images != null &&
                                apartment.images!.isNotEmpty
                            ? Image.network(
                                apartment.images![0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      AppAssets.imageC,
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(AppAssets.imageC, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(AppAssets.star, width: 14.w),
                              SizedBox(width: 4.w),
                              Text(
                                apartment.ratingLabel,
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                apartment.name ?? l10n.noName,
                                style: theme.textTheme.labelMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "EGP ${apartment.price?.toInt() ?? 0}",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  TextSpan(
                                    text: " /mo",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Image.asset(AppAssets.locationOrange, width: 14.w),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                apartment.displayLocationLabel,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildFeature(
                              context,
                              AppAssets.bedroomsIcon,
                              "${apartment.bedrooms ?? 0} Beds",
                            ),
                            SizedBox(width: 16.w),
                            _buildFeature(
                              context,
                              AppAssets.bathroomsIcon,
                              "${apartment.bathrooms ?? 0} Baths",
                            ),
                            SizedBox(width: 16.w),
                            _buildFeature(
                              context,
                              AppAssets.livingRoomsIcon,
                              "${apartment.livingRooms ?? 0} Living",
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.disabledColor,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                color: theme.primaryColor,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "People: ${apartment.availablePeople ?? apartment.maxPeople ?? 1}/${apartment.maxPeople ?? 1} available",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showApartmentClients(apartment),
                                icon: Icon(
                                  Icons.people_alt_outlined,
                                  size: 18.sp,
                                ),
                                label: const Text("Clients"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.primaryColor,
                                  side: BorderSide(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editApartmentRoute,
                                    arguments: apartment,
                                  );
                                },
                                icon: Icon(Icons.edit_rounded, size: 15.sp),
                                label: Text(
                                  l10n.editListing,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11.sp),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 9.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: IconButton(
                                onPressed: () =>
                                    _showDeleteDialog(apartment.id!),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 22.sp,
                                ),
                                tooltip: l10n.delete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFeature(BuildContext context, String asset, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          asset,
          width: 16.w,
          color: theme.primaryColor.withValues(alpha: 0.7),
        ),
        SizedBox(width: 4.w),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  void _showApartmentClients(ApartmentResponse apartment) {
    final theme = Theme.of(context);
    final bookings = _ownerBookings
        .where((booking) => booking.apartmentId == apartment.id)
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: theme.highlightColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    "Clients booking this apartment",
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    apartment.name ?? "Apartment",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16.h),
                  if (_isLoadingBookings)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      ),
                    )
                  else if (_bookingsError != null)
                    Expanded(
                      child: Center(
                        child: Text(
                          _bookingsError!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else if (bookings.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No clients booked this apartment yet.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: bookings.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) =>
                            _buildClientBookingTile(bookings[index]),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClientBookingTile(BookingResponse booking) {
    final theme = Theme.of(context);
    final status = _normalizeStatus(booking.status);
    final phone = booking.clientPhoneNumber?.trim();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.disabledColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_outline_rounded,
              color: theme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.clientName ?? "Client",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    _StatusPill(
                      label: _statusLabel(status),
                      color: _statusColor(status),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 15.sp,
                      color: theme.highlightColor,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        phone == null || phone.isEmpty
                            ? "Phone not available"
                            : phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          IconButton(
            onPressed: booking.clientId == null || booking.clientId!.isEmpty
                ? null
                : () => _openClientChat(booking),
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: theme.primaryColor,
              size: 22.sp,
            ),
            tooltip: "Chat",
          ),
        ],
      ),
    );
  }

  void _openClientChat(BookingResponse booking) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.chatRoute,
      arguments: {
        'receiverId': booking.clientId,
        'receiverName': booking.clientName ?? 'Client',
        'receiverPhotoUrl': null,
      },
    );
  }

  String _normalizeStatus(String? status) {
    final value = status?.toLowerCase().trim();
    if (value == 'accepted') return 'confirmed';
    if (value == 'canceled') return 'cancelled';
    return value == null || value.isEmpty ? 'pending' : value;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return "Confirmed";
      case 'rejected':
        return "Rejected";
      case 'cancelled':
        return "Cancelled";
      case 'pending':
      default:
        return "Pending";
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.deepOrange;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.r),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.home_work_outlined,
              size: 70.sp,
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 24.h),
          Text(l10n.noApartmentsFound, style: theme.textTheme.titleMedium),
          SizedBox(height: 10.h),
          Text(
            "You haven't listed any apartments yet.\nStart by adding your first property!",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addApartmentRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child:  Text(l10n.addNewListing),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String apartmentId) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10.w),
            Text(l10n.deleteListingTitle, style: theme.textTheme.titleMedium),
          ],
        ),
        content: Text(
          l10n.deleteListingConfirm,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: theme.textTheme.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final user = context.read<UserViewModel>().user;
              final userId = user?.id;
              if (userId != null && userId.isNotEmpty) {
                context.read<ApartmentViewModel>().deleteApartment(
                      apartmentId,
                      userId,
                    );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child:  Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
