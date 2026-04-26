import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/di/di.dart';
import 'package:sokon/core/model/notification.dart';
import 'package:sokon/core/utils/app_routes.dart';
import 'package:sokon/supabase_utils.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/back_container.dart';
import 'cubit/notification_states.dart';
import 'cubit/notification_view_model.dart';

class NotifactionScreen extends StatefulWidget {
  const NotifactionScreen({super.key});

  @override
  State<NotifactionScreen> createState() => _NotifactionScreenState();
}

class _NotifactionScreenState extends State<NotifactionScreen> {
  final NotificationViewModel viewModel = getIt<NotificationViewModel>();
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final userId = context.read<UserViewModel>().user?.id;
      if (userId != null && userId.isNotEmpty) {
        viewModel.listenToNotifications(userId).then((_) {
          viewModel.markAllAsRead(userId);
        });
      }
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationViewModel, NotificationStates>(
      bloc: viewModel,
      builder: (context, state) {
        final notifications = state is NotificationLoaded
            ? state.notifications
            : const <AppNotification>[];

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BackContainer(),
                  SizedBox(height: 20.h),
                  Text("Notification", style: AppStyles.bold24Primary),
                  SizedBox(height: 20.h),
                  if (state is NotificationLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is NotificationError)
                    Expanded(
                      child: Center(child: Text("Error: ${state.message}")),
                    )
                  else if (notifications.isEmpty)
                    const Expanded(
                      child: Center(child: Text("No notifications yet")),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationCard(context, notification);
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

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
  ) {
    final createdAt = notification.createdAt;
    final timeText = createdAt == null
        ? ""
        : DateFormat('dd MMM, hh:mm a').format(createdAt);
    final isUnread = notification.isRead != true;

    return InkWell(
      onTap: () => _handleNotificationTap(context, notification),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.offWhiteColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.grayColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: AppColors.transparentColor,
              child: Image.asset(
                _getNotificationAsset(notification.type),
                width: 52.w,
                height: 52.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ??
                              _getNotificationTitle(notification.type),
                          style: AppStyles.bold16PrimaryColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: AppColors.redColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  AutoSizeText(
                    notification.body ?? "",
                    style: AppStyles.medium12gray,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SizedBox(height: 12.h),
                  Text(timeText, style: AppStyles.regular12gray),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
  ) async {
    if (notification.id != null && notification.isRead != true) {
      await viewModel.markAsRead(notification.id!);
    }

    if (notification.type == 'new_message' && notification.senderId != null) {
      final sender = await SupabaseUtils.readUserFromSupabase(
        notification.senderId!,
      );
      if (!context.mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.chatRoute,
        arguments: {
          'receiverId': notification.senderId,
          'receiverName': sender?.name ?? notification.title ?? 'User',
          'receiverPhotoUrl': sender?.photoUrl,
        },
      );
    }
  }

  String _getNotificationTitle(String? type) {
    switch (type) {
      case 'booking_accepted':
        return 'Booking Accepted';
      case 'booking_cancelled':
        return 'Booking Cancelled';
      case 'new_message':
        return 'New Message';
      default:
        return 'Notification';
    }
  }

  String _getNotificationAsset(String? type) {
    switch (type) {
      case 'new_message':
        return AppAssets.avatar;
      default:
        return AppAssets.notification;
    }
  }
}
