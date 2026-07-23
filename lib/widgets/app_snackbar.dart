import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';
import 'common_text.dart';

class AppSnackBar {
  static void showErrorSnackBar({
    required String message,
    bool isError = false,
    int dismisDuration = 2,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      "",
      "",
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      borderRadius: 12.r,
      snackStyle: SnackStyle.FLOATING,

      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CommonText(
              string: message,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              color: AppColors.whiteColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          5.horizontalSpace,
          GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.close, color: AppColors.whiteColor, size: 16.sp),
          ),
        ],
      ),
      titleText: const SizedBox(height: 0, width: 0),
      backgroundColor: isError
          ? AppColors.redColor
          : AppColors.mainPrimaryColor,
      animationDuration: const Duration(milliseconds: 500),
      duration: Duration(seconds: dismisDuration),
      colorText: AppColors.whiteColor,
      // isDismissible: false,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h, bottom: 10.h),
    );
  }
}
