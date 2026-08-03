import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/app_colors.dart';

class AppDialog {
  static Future<T?> commonDialog<T>({
    Color? bgColor,
    required Widget childs,
    Color? borderColor,
    bool barrierDismiss = true,
  }) {
    return showGeneralDialog<T>(
      context: Get.context!,
      barrierDismissible: barrierDismiss,
      barrierLabel: "",
      transitionDuration: Duration(milliseconds: 200),
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
              canPop: barrierDismiss,
              child: Dialog(
                backgroundColor: bgColor ?? AppColors.whiteColor,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                    bottom: Radius.circular(12.r),
                  ),
                  side: BorderSide(
                    color: borderColor ?? AppColors.transparentColor,
                  ),
                ),
                child: Padding(padding: EdgeInsets.all(16.w), child: childs),
              ),
            ),
          ),
        );
      },
    );
  }
}
