import 'package:e_taxi/feature/trip_activity/model/trip_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../home/widget/originDestinationTime.dart';

class RideDetailsWidget extends StatelessWidget {
  const RideDetailsWidget({required this.trip, super.key});

  final Trip? trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigation.pushNamed(Routes.tripActivityDetailScreen, arg: trip);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
          color: AppColors.whiteColor,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              string:
                  "${trip?.bookingCode} | ${Utils().convertFullTime(trip?.createdAt ?? "")}",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
            Divider(color: AppColors.textFieldBorderColor),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CommonText(
                    string: trip?.status == "completed"
                        ? '${Utils.formatCurrency(trip?.financial?.fareBreakdown?.totalAmount)} | ${Utils.formatDistance(trip?.financial?.distance)} | ${Utils.formatDuration(trip?.financial?.duration)}'
                        : Utils.cancellationReasonLabel(
                            trip?.cancellation?.reason,
                          ),
                    softWrap: true,
                    fontSize: 14.sp,
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: getBgColor(trip?.status ?? ""),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CommonText(
                    string: Utils.tripStatusLabel(trip?.status),
                    fontSize: 14.sp,

                    color: getTextColor(trip?.status ?? ""),
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.textFieldBorderColor),
            OriginDestinationTimeWidget(
              otitle: Utils().getString(trip?.pickupAddress ?? "").first,
              osubtitle: Utils().getString(trip?.pickupAddress ?? "").last,
              dtitle: Utils().getString(trip?.dropoffAddress ?? "").first,
              dsubtitle: Utils().getString(trip?.dropoffAddress ?? "").last,
            ),
          ],
        ),
      ),
    );
  }

  Color getTextColor(String value) {
    switch (value.toLowerCase()) {
      case "completed":
        return AppColors.successColor;
      case "accepted":
      case "arrived":
      case "started":
        return AppColors.mainPrimaryColor;
      case "cancelled":
      case "canceled":
        return AppColors.warningColor;
      default:
        return AppColors.errorColor;
    }
  }

  Color getBgColor(String value) {
    switch (value.toLowerCase()) {
      case "completed":
        return AppColors.sucessContainer;
      case "accepted":
      case "arrived":
      case "started":
        return AppColors.primaryContainer;
      case "cancelled":
      case "canceled":
        return AppColors.warningBgColor;
      default:
        return AppColors.errorBgColor;
    }
  }
}

class RideDetailsLoadingWidget extends StatelessWidget {
  const RideDetailsLoadingWidget({
    required this.bgColor,
    required this.mainColor,
    super.key,
  });

  final Color mainColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
          color: AppColors.whiteColor,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              string: "#VTAXI | 2026.07.29. 08:45",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
            Divider(color: AppColors.textFieldBorderColor),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CommonText(
                    string: "1 260 Ft | 4,1 km",
                    softWrap: true,
                    fontSize: 14.sp,
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CommonText(
                    string: AppString.completed.tr,
                    fontSize: 14.sp,
                    color: mainColor,
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.textFieldBorderColor),
            OriginDestinationTimeWidget(
              otitle: "Veszprém, indulási cím",
              osubtitle: "Felvételi pont",
              dsubtitle: "Úti cél",
              dtitle: "Veszprém, érkezési cím",
            ),
          ],
        ),
      ),
    );
  }
}
