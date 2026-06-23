import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';

import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_routes.dart';

class FeaturedEstatesCard extends StatelessWidget {
  final ApartmentResponse apartment;
  const FeaturedEstatesCard({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.apartmentDetailsRoute, arguments: apartment),

      child: SizedBox(
        height: 175.h,
        child: Container(
          width: 310.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: theme.disabledColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: apartment.images != null && apartment.images!.isNotEmpty
                    ? Image.network(
                        apartment.images![0],
                        width: 140.w,
                        height: 155.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              AppAssets.image,
                              width: 140.w,
                              height: 155.h,
                              fit: BoxFit.cover,
                            ),
                      )
                    : Image.asset(
                        AppAssets.image,
                        width: 140.w,
                        height: 155.h,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AutoSizeText(
                      apartment.name ?? "No Name",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall,
                    ),
                    Row(
                      children: [
                        Image.asset(AppAssets.star, width: 14.w),
                        SizedBox(width: 4.w),
                        Text(
                          apartment.ratingLabel,
                          style: theme.textTheme.displaySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(AppAssets.locationIcon, width: 14.w),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            apartment.displayLocationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.displaySmall,
                          ),
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "EG ${apartment.price ?? 0}/",
                            style: theme.textTheme.displaySmall,
                          ),
                          TextSpan(
                            text: "month",
                            style: theme.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
