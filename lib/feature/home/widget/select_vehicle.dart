import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/cachenetworkimage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/utils.dart';
import '../model/create_booking_model.dart';

class SelectVehicleWidget extends StatelessWidget {
  const SelectVehicleWidget({
    required this.rideOption,
    required this.borderEnable,
    required this.onTap,
    required this.newAmount,
    super.key,
  });

  final VoidCallback onTap;
  final bool borderEnable;

  final RideOption? rideOption;

  final String newAmount;

  String _vehicleName() {
    final String raw = (rideOption?.type ?? '').trim();
    final String withoutCity = raw.replaceFirst(
      RegExp(r'\s*Veszpr[eé]m$', caseSensitive: false),
      '',
    ).trim();
    return withoutCity.isEmpty ? (raw.isEmpty ? 'Normál taxi' : raw) : withoutCity;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: borderEnable
                ? AppColors.mainPrimaryColor
                : AppColors.textFieldBorderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 62.w,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.mainPrimaryColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: NetworkImageWidget(
                image: rideOption?.icon ?? "",
                ht: 54.w,
                wt: 64.w,
                boxFit: BoxFit.contain,
                errorWidget: Image.asset(
                  IconAsset.driverMarker,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommonText(
                        string: _vehicleName(),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      CustomImage(
                        image: IconAsset.person,
                        ht: 18.w,
                        wt: 18.w,
                      ),
                      4.horizontalSpace,
                      CommonText(
                        string: rideOption?.capacity ?? "",
                        fontSize: 12.sp,
                        color: AppColors.textCaptionColor,
                      ),
                      8.horizontalSpace,
                      CustomImage(
                        image: IconAsset.time,
                        ht: 18.w,
                        wt: 18.w,
                      ),
                      4.horizontalSpace,
                      CommonText(
                        string: rideOption?.estimatedTime ?? "",
                        fontSize: 12.sp,
                        color: AppColors.textCaptionColor,
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  CommonText(
                    string: rideOption?.description ?? "",
                    fontSize: 12.sp,
                    color: AppColors.textCaptionColor,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonText(
                  string: Utils.formatCurrency(
                    newAmount.isNotEmpty
                        ? newAmount
                        : (rideOption?.currentPrice ?? "0"),
                  ),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                if ((rideOption?.hasDiscount ?? "") == "1")
                  CommonText(
                    string: Utils.formatCurrency(
                      rideOption?.originalPrice ?? "0",
                    ),
                    fontSize: 12.sp,
                    color: AppColors.textCaptionColor,
                    textDecoration: TextDecoration.lineThrough,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
