import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';

class AppDialog {
  static Future<T?> commonDialog<T>({
    required Widget childs,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 400),
    Color barrierColor = AppColors.transparent,
    EdgeInsets? padding,
    ShapeBorder shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  }) {
    return showGeneralDialog<T>(
      context: Get.context!,
      barrierDismissible: barrierDismissible,
      barrierLabel: "",
      transitionDuration: Duration(milliseconds: 300),
      fullscreenDialog: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: PopScope(
              canPop: barrierDismissible,
              child: Dialog(
                insetPadding: padding,
                backgroundColor: AppColors.whiteColor,
                shape: shape,
                child: Padding(padding: EdgeInsets.all(16.w), child: childs),
              ),
            ),
          ),
        );
      },
    );
  }

  static commonBottomSheetWidget({
    required Widget child,
    bool isDismiss = true,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: isDismiss,
      isScrollControlled: true,
      enableDrag: isDismiss,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return SafeArea(
          child: PopScope(
            canPop: isDismiss,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor, // Dark gray background
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
}
