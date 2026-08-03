import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vector_math/vector_math_64.dart';

import '../utils/app_string.dart';

class CustomWidget {
  static Future<XFile?> takeImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source);
    return file;
  }

  static commonBottomSheetWidget({
    required String title,
    required VoidCallback onTap,
    required List<Widget> child,
    bool isDismiss = true,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: isDismiss,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return SafeArea(
          child: PopScope(
            canPop: isDismiss,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 8.w,
                          width: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBorderColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      18.verticalSpace,
                      CommonText(
                        string: title,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      Divider(
                        color: AppColors.textFieldBorderColor,
                      ).paddingSymmetric(vertical: 4.h),
                      24.verticalSpace,
                      ...child,
                      24.verticalSpace,
                      CustomButton(text: AppString.apply.tr, onTap: onTap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static commonBottomSheetWidget1({
    required Widget child,
    bool isDismiss = true,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: isDismiss,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return SafeArea(
          child: PopScope(
            canPop: isDismiss,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget iconChange({required Widget child}) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scaleByVector3(
          Vector3(
            Get.locale == Locale('ar', 'AE') ? -1.0 : 1.0,
            1.0,
            1.0,
          ),
        ),
      child: child,
    );
  }
}
