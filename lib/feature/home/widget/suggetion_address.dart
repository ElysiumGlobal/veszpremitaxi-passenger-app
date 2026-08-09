import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuggestionAddressWidget extends StatelessWidget {
  const SuggestionAddressWidget({
    required this.onTap,
    required this.title,
    required this.subTitle,
    super.key,
  });

  final String title;
  final String subTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.brandNavy.withValues(alpha: .08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandNavy.withValues(alpha: .07),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.brandNavy,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.mainPrimaryColor,
                  size: 19.w,
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      string: title,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandNavy,
                    ),
                    2.verticalSpace,
                    CommonText(
                      string: subTitle,
                      fontSize: 11.sp,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textCaptionColor,
                    ),
                  ],
                ),
              ),
              6.horizontalSpace,
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.w,
                color: AppColors.mainPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
