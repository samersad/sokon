import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';

class CircleAvatarContainer extends StatelessWidget {
  const CircleAvatarContainer({super.key,required this.image});
  final  String image;

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.black,
            width: 1
        ),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFB9D6FA),
        radius: 30.r,
        child: Image.asset(
          image,
        ),
      ),
    );
  }
}
