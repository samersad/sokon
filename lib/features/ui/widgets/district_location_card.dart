import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/model/district_summary.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_styles.dart';

class DistrictLocationCard extends StatelessWidget {
  final DistrictSummary districtSummary;
  final VoidCallback onTap;
  final bool compact;

  const DistrictLocationCard({
    super.key,
    required this.districtSummary,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10.w : 14.w,
          vertical: compact ? 10.h : 14.h,
        ),
        decoration: BoxDecoration(
          color: theme.disabledColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.highlightColor.withOpacity(0.35)),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(AppAssets.locationIcon, width: 16.w),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          districtSummary.district,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${districtSummary.apartmentCount} apartments",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.medium12gray,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    districtSummary.district,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "${districtSummary.apartmentCount} apartments",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
