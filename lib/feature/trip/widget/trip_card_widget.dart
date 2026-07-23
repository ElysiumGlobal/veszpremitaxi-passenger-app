import 'package:e_taxi/feature/trip/model/trip_details_model.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../widgets/cachenetworkimage.dart';

class TripCardWidget extends StatelessWidget {
  TripCardWidget({required this.tripHistory, super.key});

  final imageList = [
    IconAsset.bike,
    IconAsset.autoRickshaw,
    IconAsset.car,
    IconAsset.premiumCar,
  ];

  final TripHistory tripHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.whiteColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NetworkImageWidget(
            image: tripHistory.rideType?.icon ?? "",
            wt: 34.w,
            ht: 34.w,
          ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        string:
                            "${tripHistory.rideType?.rideTypeName ?? ""} Ride",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: getBgColor(tripHistory.tripInfo?.status ?? ""),
                      ),
                      child: CommonText(
                        string: tripHistory.tripInfo?.status ?? "",
                        color: getTextColor(tripHistory.tripInfo?.status ?? ""),
                      ),
                    ),
                  ],
                ),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      string: Utils().convertFullTime(
                        tripHistory.tripInfo?.createdAt ?? "",
                      ),
                      fontSize: 14.sp,
                      color: AppColors.textCaptionColor,
                    ),
                  ],
                ),
                6.verticalSpace,
                CommonText(
                  string: tripHistory.locations?.dropoffAddress ?? "",
                  fontSize: 14.sp,
                  color: AppColors.textCaptionColor,
                  softWrap: true,
                ),
                if ((tripHistory.tripInfo?.bookingCode ?? "").isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        string: "${AppString.bookingCode.tr} : ",
                        color: AppColors.textCaptionColor,
                      ),
                      CommonText(
                        string: tripHistory.tripInfo?.bookingCode ?? "",
                      ),
                    ],
                  ).paddingOnly(top: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getTextColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.successColor;
      case "cancelled":
        return AppColors.errorColor;
      default:
        return AppColors.warningColor;
    }
  }

  Color getBgColor(String value) {
    switch (value) {
      case "completed":
        return AppColors.sucessContainer;
      case "cancelled":
        return AppColors.errorBgColor;
      default:
        return AppColors.warningBgColor;
    }
  }
}

class TripCardWidgetShimmer extends StatelessWidget {
  TripCardWidgetShimmer({super.key});

  final List<String> imageList = [
    IconAsset.bike,
    IconAsset.autoRickshaw,
    IconAsset.car,
    IconAsset.premiumCar,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.whiteColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomImage(image: imageList[1], wt: 34.w, ht: 34.w),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonText(
                        string: "Auth Ride",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: 0 == 0
                            ? AppColors.errorBgColor
                            : 0 == 1
                            ? AppColors.warningBgColor
                            : AppColors.sucessContainer,
                      ),
                      child: CommonText(
                        string: "Cancel",
                        color: 0 == 0
                            ? AppColors.errorColor
                            : 0 == 1
                            ? AppColors.warningColor
                            : AppColors.successColor,
                      ),
                    ),
                  ],
                ),
                10.verticalSpace,
                CommonText(
                  string: "05 Aug 2025, 09:33 AM",
                  fontSize: 14.sp,
                  color: AppColors.textCaptionColor,
                ),
                10.verticalSpace,
                CommonText(
                  string: "Shree Swaminarayan mandir-Bhuj kutch-370001",
                  fontSize: 14.sp,
                  color: AppColors.textCaptionColor,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
