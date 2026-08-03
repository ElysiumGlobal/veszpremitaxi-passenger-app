import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import '../utils/app_string.dart';
import 'common_text.dart';

class DriverRideOverviewWidget extends StatelessWidget {
  const DriverRideOverviewWidget({
    required this.bgColor,
    required this.timeOnline,
    required this.avgRating,
    required this.totalRide,
    required this.complete,
    required this.completeRate,
    super.key,
  });

  final String timeOnline;
  final String totalRide;
  final String complete;
  final String completeRate;
  final String avgRating;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: bgColor,
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TitleSubTitle1612(
                    title: timeOnline,
                    body: AppString.timeOnline.tr,
                  ),
                ),
                VerticalDivider(color: AppColors.textFieldBorderColor),
                Expanded(
                  child: TitleSubTitle1612(
                    title: "$totalRide",
                    body: AppString.totalRide.tr,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.textFieldBorderColor,
          ).paddingSymmetric(vertical: 8.h),
          CCRARWidget(
            avgRating: avgRating,
            completeRate: completeRate,
            complete: complete,
          ),
        ],
      ),
    );
  }
}

class CCRARWidget extends StatelessWidget {
  const CCRARWidget({
    required this.avgRating,
    required this.completeRate,
    required this.complete,
    super.key,
  });

  final String complete;
  final String completeRate;
  final String avgRating;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: TitleSubTitle1612(
              title: "$complete",
              body: AppString.completed.tr,
            ),
          ),
          VerticalDivider(color: AppColors.textFieldBorderColor),
          Expanded(
            child: TitleSubTitle1612(
              title: completeRate,
              body: AppString.completionRate.tr,
            ),
          ),
          VerticalDivider(color: AppColors.textFieldBorderColor),
          Expanded(
            child: TitleSubTitle1612(
              title: avgRating,
              body: AppString.avgRating.tr,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleSubTitle1612 extends StatelessWidget {
  const TitleSubTitle1612({
    required this.title,
    required this.body,
    this.alignment = CrossAxisAlignment.center,
    this.isSelected = false,
    super.key,
  });

  final String title;
  final String body;
  final CrossAxisAlignment alignment;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        CommonText(
          string: title,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? AppColors.mainPrimaryColor
              : AppColors.titleTextColor,
        ),
        CommonText(
          string: body,
          color: isSelected
              ? AppColors.mainPrimaryColor
              : AppColors.textSecondaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 12.sp,
        ),
      ],
    );
  }
}
