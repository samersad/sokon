import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';

class LabeledInfoField extends StatelessWidget {
  const LabeledInfoField({
    super.key,
    required this.label,
    required this.child,
    this.explanation,
  });

  final String label;
  final Widget child;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: (theme.textTheme.bodyMedium ?? AppStyles.regular15black)
                    .copyWith(
                  color: theme.highlightColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
              if (explanation != null && explanation!.isNotEmpty) ...[
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () => _showExplanationDialog(context),
                  child: Icon(
                    Icons.info_outline,
                    color: isDark ? AppColors.whiteColor.withOpacity(0.6) : AppColors.primaryColor,
                    size: 17.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }

  void _showExplanationDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: theme.cardColor,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: (theme.textTheme.titleMedium ?? AppStyles.medium16black)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            explanation!,
            style: (theme.textTheme.bodyMedium ?? AppStyles.regular14gray).copyWith(
              color: theme.highlightColor.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Got it",
                style: AppStyles.bold14Primary,
              ),
            ),
          ],
        );
      },
    );
  }
}
