import 'package:e_taxi/utils/app_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_button.dart';
import 'origin_destination_widget.dart';

class TripDetailsModal extends StatelessWidget {
  const TripDetailsModal({
    required this.price,
    required this.destination,
    required this.origin,
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;
  final String origin;
  final String destination;
  final String price;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.hintTextColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            CommonText(
              string: AppString.tripDetails.tr,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.titleTextColor,
            ),
            SizedBox(height: 20.h),

            OriginDestinationWidget(origin: origin, destination: destination),
            SizedBox(height: 20.h),

            // Total Amount
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: AppColors.textFieldBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    string: "Total Amount",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleTextColor,
                  ),
                  CommonText(
                    string: Utils.formatCurrency(price),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleTextColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppString.cancelRide.tr,
                    buttonColor: AppColors.warningBgColor,
                    textColor: AppColors.errorColor,
                    borderColor: AppColors.errorColor,
                    height: 48.h,
                    onTap: () {
                      Navigator.pop(context);
                      onTap();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: AppString.close.tr,
                    buttonColor: AppColors.blackColor,
                    textColor: AppColors.whiteColor,
                    height: 48.h,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
