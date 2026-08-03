import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';

class GoOnlineButton extends StatelessWidget {
  const GoOnlineButton({
    required this.onTap,
    this.bgColor,
    this.title,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onTap;
  final Color? bgColor;
  final String? title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: Material(
        color: isLoading
            ? (bgColor ?? AppColors.mainPrimaryColor).withValues(alpha: .72)
            : (bgColor ?? AppColors.mainPrimaryColor),
        borderRadius: BorderRadius.circular(18.r),
        elevation: isLoading ? 0 : 8,
        shadowColor: (bgColor ?? AppColors.mainPrimaryColor).withValues(alpha: .35),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    Icons.local_taxi_rounded,
                    color: AppColors.whiteColor,
                    size: 25.sp,
                  ),
                11.horizontalSpace,
                Text(
                  title ?? 'Munkába állok',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
