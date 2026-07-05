import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sokon/core/utils/app_colors.dart';


class CircleAvatarContainer extends StatelessWidget {
  const CircleAvatarContainer({super.key,required this.image});
  final  String image;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.pureBlack,
            width: 1
        ),
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.avatarBlue,
        radius: 30.r,
        child: Image.asset(
          image,
        ),
      ),
    );
  }
}
