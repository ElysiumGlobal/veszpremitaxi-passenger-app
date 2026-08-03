import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/custome_img.dart';

class IconWidgets extends StatelessWidget {
  const IconWidgets({
    this.bgColor,
    this.ht,
    required this.onTap,
    required this.icon,
    super.key,
  });

  final String icon;
  final VoidCallback onTap;
  final double? ht;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: ht ?? 44.h,
        width: ht ?? 44.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor ?? AppColors.whiteColor,
        ),
        alignment: Alignment.center,
        child: CustomImage(image: icon, ht: 24.h, wt: 24.h),
      ),
    );
  }
}
