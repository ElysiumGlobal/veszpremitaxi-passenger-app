import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors.dart';
import 'common_text.dart';
import 'custome_img.dart' show CustomImage;

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    super.key,
    required this.icon,
    required this.subTitle,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImage(image: icon, ht: 238.h, wt: 238.w),
            24.verticalSpace,
            CommonText(
              string: title,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
            8.verticalSpace,
            CommonText(string: subTitle, color: AppColors.textCaptionColor),
          ],
        ),
      ),
    );
  }
}
