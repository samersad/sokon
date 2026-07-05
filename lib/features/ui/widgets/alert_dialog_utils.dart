import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

class AlertDialogUtils {
  static void showLoading({required BuildContext context, required String msg}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              SizedBox(width: 20.w),
              Expanded(
                child: Text(
                  msg,
                  style: AppStyles.semiBold14Primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading({required BuildContext context}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void showMessage({
    required BuildContext context,
    required String msg,
    String? title,
    Widget? pos,
    VoidCallback? posAction,
    Widget? nav,
    VoidCallback? navAction,
  }) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: title != null
              ? Text(title, style: AppStyles.bold20blackIner)
              : null,
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.4.sh),
            child: SingleChildScrollView(
              child: Text(msg, style: AppStyles.medium16black),
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
          actions: [
            Row(
              children: [
                if (nav != null)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        navAction?.call();
                      },
                      child: Center(child: nav),
                    ),
                  ),
                if (nav != null && pos != null) SizedBox(width: 10.w),
                if (pos != null)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        posAction?.call();
                      },
                      child: Center(child: pos),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
