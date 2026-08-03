import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/common_text.dart';

Widget titlePriceTrip(
  String title,
  String price, {
  double? size,
  Color? color,
  FontWeight? fontWt,
}) {
  return GestureDetector(
    onTap: () {},
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(
          string: title,
          fontSize: size,
          color: color,
          fontWeight: fontWt ?? FontWeight.w400,
        ),
        CommonText(
          string: price,
          fontSize: size,
          color: color,
          fontWeight: fontWt ?? FontWeight.w400,
        ),
      ],
    ).paddingOnly(bottom: 8.h),
  );
}

Widget containerWidgetTrip(Widget child) {
  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.textFieldBorderColor),
      color: AppColors.whiteColor,
    ),
    child: child,
  );
}
