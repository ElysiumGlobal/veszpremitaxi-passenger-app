import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/cachenetworkimage.dart';
import '../../../widgets/common_text.dart';

class DriverDetailsWidget extends StatelessWidget {
  const DriverDetailsWidget({
    required this.thirdText,
    required this.firstText,
    required this.secoundText,
    required this.image,
    this.rating,
    this.radius = 0,
    super.key,
  });

  final String firstText;
  final String secoundText;
  final String thirdText;
  final String image;
  final double radius;
  final String? rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                string: firstText,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
              CommonText(
                string: secoundText,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.textCaptionColor,
              ),
              CommonText(
                string: thirdText,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.textCaptionColor,
              ),
            ],
          ),
        ),
        Column(
          children: [
            NetworkImageWidget(
              image: image,
              ht: 44.w,
              wt: 44.w,
              radius: radius,
            ),
            4.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mainPrimaryColor),
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.primaryContainer,
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppColors.mainPrimaryColor),
                  CommonText(string: rating ?? "4.5"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
